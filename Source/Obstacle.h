//
//  Obstacle.h
//  FlappyBirdUP
//
//  Created by Wenjia Ma on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Obstacle : CCNode

- (void)setupRandomPosition;
- (void)loadWeapon;
- (void)loadSuperPower;

@end
