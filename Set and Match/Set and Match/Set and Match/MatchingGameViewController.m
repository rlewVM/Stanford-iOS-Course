//
//  MatchingGameViewController.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "MatchingGameViewController.h"
#import "CardMatchingGame.h"
#import "PlayingCardDeck.h"

@interface MatchingGameViewController ()

@end

@implementation MatchingGameViewController

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

- (CardGame *)createGameWithCardCount:(NSInteger)count
{
    return [[CardMatchingGame alloc] initWithCardCount:count usingDeck:[self createDeck]];
}

- (void)updateButtonAppearance:(UIButton *)button whenCardSelected:(Card *)card
{
    [button setAttributedTitle:[self cardToAttributedString:card] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"cardfront"] forState:UIControlStateNormal];
}

- (void)updateButtonAppearance:(UIButton *)button whenCardUnselected:(Card *)card
{
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:@""] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"cardbackBlue"] forState:UIControlStateNormal];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
