//
//  CardMatchingGame.h
//  Card Game
//
//  Created by Rachel Lew on 2/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

static const int MATCH_BONUS = 4;
static const int FLIP_COST = 1;
static const int MISMATCH_PENALTY = 1;

@interface CardMatchingGame : NSObject

@property (nonatomic, readonly) int score;
@property (nonatomic, readwrite) BOOL multiCardMatch;
@property (nonatomic, readonly) NSString *moveMessage;

- (instancetype) initWithCardCount:(NSUInteger) count usingDeck:(Deck *) deck;

- (Card *) cardAtIndex:(NSInteger) index;
- (void) chooseCardAtIndex:(NSInteger) index;

@end
