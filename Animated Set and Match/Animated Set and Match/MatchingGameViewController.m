//
//  MatchingGameViewController.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "MatchingGameViewController.h"
#import "CardMatchingGameConstants.h"
#import "PlayingCardDeck.h"
#import "PlayingCardView.h"

@interface MatchingGameViewController ()

@end

@implementation MatchingGameViewController

#define INITIAL_CARDS_IN_PLAY ((NSUInteger) 24)

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

- (CardGame *)createGame
{
    return [[CardGame alloc] initWithCardCount:INITIAL_CARDS_IN_PLAY usingDeck:self.cards andConstants:[CardMatchingGameConstants new]];
}

- (void)initializeCardViewInGrid:(CardGame *)game
{
    self.cardGridView.cardCount = INITIAL_CARDS_IN_PLAY;
    for (int i = 0; i < INITIAL_CARDS_IN_PLAY; i++) {
        Card *card = [game cardAtIndex:i];
        UIView *view = [self createSubviewWithCard:card withTag:i];
        [self.cardGridView addSubview:view];
    }
}

- (BOOL)shouldFlipView:(CardView *)view withCard:(Card *)card
{
    return (card.isChosen && !view.isFaceup) || (!card.isChosen && view.isFaceup);
}

- (CardView *)createSubviewWithCard:(Card *)card withTag:(NSUInteger)tag
{
    PlayingCardView *view = [[PlayingCardView alloc] initWithCard:card];
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(tapToChoose:)]];
    view.tag = tag;
    return view;
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
