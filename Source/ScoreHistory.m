//
//  ScoreHistory.m
//  FlappyBirdUP
//
//  Created by Wenjia Ma on 8/8/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ScoreHistory.h"

@implementation ScoreHistory {
    NSUserDefaults *_records;
    
    CCLabelTTF *_scoreHistory;
    CCLabelTTF *_currentScore;
    CCLabelTTF *_bestScore;
}

- (void)didLoadFromCCB {
    _records = [NSUserDefaults standardUserDefaults];
}

- (void)setCurrent:(NSInteger) cur {
    _currentScore.string = [NSString stringWithFormat:@"%d", cur];
}

- (void)setHistory:(NSInteger) cur {
    NSInteger bestInHistory = [_records integerForKey:@"highestScore"];
    if (cur > bestInHistory) {
        bestInHistory = cur;
        [_records setInteger:cur forKey:@"highestScore"];
        _scoreHistory.string = @"New High Score:";
    }
    else
        _scoreHistory.string = @"Best Score:";
    
    _bestScore.string = [NSString stringWithFormat:@"%d", bestInHistory];
}

- (void)resetHistory {
    [_records setInteger:0 forKey:@"highestScore"];
}

@end
