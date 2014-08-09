//
//  ScoreHistory.h
//  FlappyBirdUP
//
//  Created by Wenjia Ma on 8/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface ScoreHistory : CCNode

- (void)setCurrent:(NSInteger) cur;
- (void)setHistory:(NSInteger) cur;
- (void)resetHistory;

@end
