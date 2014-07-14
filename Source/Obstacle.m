//
//  Obstacle.m
//  FlappyBirdUP
//
//  Created by Wenjia Ma on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle {
    CCNode *_topPipe;
    CCNode *_bottomPipe;
    CCNode *_greenMushroom;
    CCNode *_redMushroom;
    CCNode *_purpleMushroom;
}

#define ARC4RANDOM_MAX      0x100000000
// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPositionTopPipe = 128.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPositionBottomPipe = 440.f;
// distance between top and bottom pipe
static const CGFloat pipeDistance = 142.f;
// calculate the end of the range of top pipe
static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;


- (void)didLoadFromCCB {
    _topPipe.physicsBody.collisionType = @"level";
    _bottomPipe.physicsBody.collisionType = @"level";
    
    _greenMushroom.physicsBody.collisionType = @"weapon";
    _greenMushroom.physicsBody.sensor = true;
    
    _redMushroom.physicsBody.collisionType = @"weapon";
    _redMushroom.physicsBody.sensor = true;
    
    _purpleMushroom.physicsBody.collisionType = @"level";
    _purpleMushroom.physicsBody.sensor = true;
}

- (void)setupRandomPosition {
    // value between 0.f and 1.f
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = maximumYPositionTopPipe - minimumYPositionTopPipe;
    _topPipe.position = ccp(_topPipe.position.x, minimumYPositionTopPipe + (random * range));
    _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y + pipeDistance);
    
    
}

- (void) loadWeapon:(int)weapon {
    if (weapon == 1) {
        _greenMushroom.visible = true;
        _greenMushroom.physicsBody.sensor = false;
        _greenMushroom.position = ccp(_topPipe.position.x, _topPipe.position.y);
    }
    else if (weapon == 2) {
        _redMushroom.visible = true;
        _redMushroom.physicsBody.sensor = false;
        _redMushroom.position = ccp(_topPipe.position.x, _topPipe.position.y);
    }
    else {
        _purpleMushroom.visible = true;
        _purpleMushroom.physicsBody.sensor = false;
        _purpleMushroom.position = ccp(_topPipe.position.x, _topPipe.position.y);
    }
    
}

- (void) loadSuperPower:(int)weapon {
    if (weapon == 1) {
        [self greenMushroomEffect];
    }
    else
        [self redMushroomEffect];
}

- (void) greenMushroomEffect { // Transparent bird
    _topPipe.physicsBody.sensor = true;
    _bottomPipe.physicsBody.sensor = true;
    _greenMushroom.physicsBody.sensor = true;
    _greenMushroom.visible = false;
}

- (void) redMushroomEffect { // Pipe explosion
    _topPipe.physicsBody.sensor = true;
    _bottomPipe.physicsBody.sensor = true;
    _topPipe.visible = false;
    _bottomPipe.visible = false;
    
    _redMushroom.physicsBody.sensor = true;
    _redMushroom.visible = false;
    
    [self brokePipeEffect:true];
    [self brokePipeEffect:false];
    
}

- (void) brokePipeEffect:(bool) top {
    CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"Explosion"];
    explosion.autoRemoveOnFinish = true;
    explosion.position = (top) ? _topPipe.position : _bottomPipe.position;
    [self addChild:explosion];
}

@end
