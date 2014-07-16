//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"

static const CGFloat firstObstaclePosition = 200.f;
static const CGFloat distanceBetweenObstacles = 160.f;
static const CGFloat speed = 80.0f;
static const CGFloat speedUpMultiplier = 1.5f;

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrderSuperpower,
    DrawingOrdeBird
};

@implementation MainScene {
    CCSprite *_bird;
    CCPhysicsNode *_physicsNode;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    bool _gameOver;
    CGFloat _scrollSpeed;
    
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    
    NSTimeInterval _weaponCountDown;
    bool _equipWeapon;
    int _weaponType;
    
    CCParticleSystem *_fire;
}

- (void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2];
    self.userInteractionEnabled = true;
    
    // Put ground to the front
    for (CCNode *ground in _grounds) {
        ground.physicsBody.collisionType = @"dead";
        ground.zOrder = DrawingOrderGround;
    }
    _physicsNode.collisionDelegate = self;
    _bird.physicsBody.collisionType = @"bird";
    _bird.zOrder = DrawingOrdeBird;
    
    // Add Obstacles
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    // Init scrolling speed
    _scrollSpeed = speed;
    
    // Init weapon control
    _weaponCountDown = 0.f;
    _equipWeapon = false;
    _weaponType = 0;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [_bird.physicsBody applyImpulse:ccp(0, 400.f)];
        [_bird.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
    }
    
}

- (void)update:(CCTime)delta {
    // Change scrollSpeed according to the weaponType
    CGFloat tmpSpeed;
    if (_equipWeapon && _weaponType == 4) {
        tmpSpeed = _scrollSpeed * speedUpMultiplier;
    }
    else
        tmpSpeed = _scrollSpeed;
    
    _bird.position = ccp(_bird.position.x + delta * tmpSpeed, _bird.position.y);
    if (_fire) _fire.position = _bird.position;
    _physicsNode.position = ccp(_physicsNode.position.x - (delta * tmpSpeed), _physicsNode.position.y);
    
    // Loop the ground
    for (CCNode *ground in _grounds) {
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        if (groundScreenPosition.x <= -1 * ground.contentSize.width) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    // clamp velocity
    float yVelocity = clampf(_bird.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _bird.physicsBody.velocity = ccp(0, yVelocity);
    
    // Rotation
    _sinceTouch += delta;
    _bird.rotation = clampf(_bird.rotation, -30.f, 90.f);
    
    if(_bird.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_bird.physicsBody.angularVelocity, -2.f, 1.f);
        _bird.physicsBody.angularVelocity = angularVelocity;
    }
    if (_sinceTouch > 0.5f) {
        [_bird.physicsBody applyAngularImpulse:-40000.f * delta];
    }
    
    // Add Obstacle
    NSMutableArray *offScreenObstacles = nil;
    for (Obstacle *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *removeObstacle in offScreenObstacles) {
        [removeObstacle removeFromParent];
        [_obstacles removeObject:removeObstacle];
        [self spawnNewObstacle];
    }
    
    // Count for Weapon
    _weaponCountDown += delta;
}

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [obstacle setupRandomPosition];
    
    // Weapon
    if (_equipWeapon && _weaponCountDown > 5.f) { // Remove weapon
        NSLog(@"withdraw weapon at %f", _weaponCountDown);
        _equipWeapon = false;
        _weaponCountDown = 0.f;
    }
    else if (_weaponCountDown > 3.f) { // Add weapon
        NSLog(@"weapon is %f", _weaponCountDown);
        _equipWeapon = false;
        
        _weaponType = 1 + arc4random() % 5; // Choose Weapon Type
        NSLog(@"%d", _weaponType);
        
        [obstacle loadWeapon:_weaponType];
        _weaponCountDown = 0.f;
    }
    
    obstacle.zOrder = DrawingOrderPipes;
    
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

- (void) onFire {
    _fire = (CCParticleSystem *)[CCBReader load:@"OnFire"];
    _fire.autoRemoveOnFinish = true;
    // _fire.position = _bird.position;
    _fire.zOrder = DrawingOrderSuperpower;
    [_bird.parent addChild:_fire];
}

- (BOOL)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair bird:(CCNode *)bird dead:(CCNode *)dead {
    [self gameOver];
    return true;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bird:(CCNode *)bird level:(CCNode *)pipe {
    if (_equipWeapon && _weaponType < 4) {
        [(Obstacle *)pipe.parent loadSuperPower:_weaponType];
    }
    else
        [self gameOver];
    return true;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bird:(CCNode *)bird goal:(CCNode *)goal {
    [goal removeFromParent];
    ++_points;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    return true;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bird:(CCNode *)bird weapon:(CCNode *)weapon {
    _weaponCountDown = 0.f;
    _equipWeapon = true;
    [self onFire];
    if (_weaponType==5) { // purple mushroom will call to dead
        [self gameOver];
    }
    [(Obstacle *)weapon.parent hideMushroom:weapon];
    
    NSLog(@"hit mushroom");
    return true;
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _bird.rotation = 90.f;
        _bird.physicsBody.allowsRotation = FALSE;
        [_bird stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}

@end
