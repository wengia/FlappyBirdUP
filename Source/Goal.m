//
//  Goal.m
//  FlappyBirdUP
//
//  Created by Wenjia Ma on 7/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"goal";
}

@end
