//
//  CardGame.h
//  Set and Match
//  Abstract class for a Card Game.
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"
#import "Card.h"

@interface CardGame : NSObject

@property (nonatomic, readonly) int score;
@property (nonatomic, readonly) int roundPoints;
@property (nonatomic, strong, readonly) NSMutableArray *cardsChosenThisTurn;

/**
 *  ABSTRACT method that returns the number of cards necessary for a match in this game. Default is 0.
 */
- (int)numCardsForMatch;
/**
 *  ABSTRACT method that returns the cost of flipping over or selecting a card in this game. Default is 0.
 */
- (int)flipCost;
/**
 *  ABSTRACT method that returns the points multiplier for when a match is found. Default is 1.
 */
- (int)matchBonus;
/**
 *  ABSTRACT method that returns the number of points subtracted when a mismatch is found. Default is 0.
 */
- (int)mismatchPenalty;

/**
 *  Initializes the game's cards using the passed in deck. "Deals" the number of cards specified by count.
 */
- (instancetype) initWithCardCount:(NSUInteger) count usingDeck:(Deck *) deck;

/**
 *  Returns the card at the given index from the dealt cards.
 */
- (Card *) cardAtIndex:(NSInteger) index;
/**
 *  Selects a card at the given index, marking it as chosen. If there are enough cards chosen to
 *  make a match, all the game's chosen cards and the newly chosen card are matched against each
 *  other and the score is updated accordingly.
 */
- (void) chooseCardAtIndex:(NSInteger) index;

@end
