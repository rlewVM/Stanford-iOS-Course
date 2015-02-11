//
//  HistoryViewController.h
//  Set and Match
//  Controller displaying the history of a given game, which is all the moves that resulted in
//  score changes.
//
//  Created by Rachel Lew on 2/10/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController

@property (strong, nonatomic) NSArray *moveList;
@property (weak, nonatomic) IBOutlet UITextView *currentGameHistory;

@end
