//
//  SetGameViewController.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCard.h"
#import "SetCardView.h"

@interface SetGameViewController ()

@end

@implementation SetGameViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (Deck *)createDeck
{
    return [SetCardDeck new];
}

#define INITIAL_CARDS_IN_PLAY ((NSUInteger) 12)
- (CardGame *)createGame
{
    return [[CardGame alloc] initWithCardCount:INITIAL_CARDS_IN_PLAY usingDeck:self.cards andConstants:[SetGameConstants new]];
}

- (void)initializeCardViewInGrid:(CardGame *)game
{
    self.cardGridView.cardCount = INITIAL_CARDS_IN_PLAY;
    self.cardGridView.aspectRatio = 60.0 / 40.0;

    for (int i = 0; i < INITIAL_CARDS_IN_PLAY; i++) {
        Card *card = [game cardAtIndex:i];
        UIView *view = [self createSubviewWithCard:card withTag:i];
        [self.cardGridView addSubview:view];
    }
}

- (CardView *)createSubviewWithCard:(Card *)card withTag:(NSUInteger)tag
{
    SetCardView *view = [[SetCardView alloc] initWithCard:card];
    view.tag = tag;
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(tapToChoose:)]];
    return view;
}

@end
