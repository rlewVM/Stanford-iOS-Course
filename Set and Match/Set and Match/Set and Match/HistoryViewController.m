//
//  HistoryViewController.m
//  Set and Match
//
//  Created by Rachel Lew on 2/10/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableAttributedString *movesAsString = [[NSMutableAttributedString alloc] init];
    
    for (NSAttributedString *move in self.moveList) {
        [movesAsString appendAttributedString:move];
        [movesAsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    self.currentGameHistory.attributedText = movesAsString;
}

@end
