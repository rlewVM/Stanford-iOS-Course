//
//  CardGame.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "CardGame.h"

@interface CardGame()

@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, readwrite) int score;
@property (nonatomic, strong, readwrite) NSMutableArray *gameHistory;    // Cards
@property (nonatomic, strong, readwrite) NSMutableArray *scoreHistory;   // NSIntegers

@end

@implementation CardGame

// Abstract
- (int)numCardsForMatch
{
    return 0;
}

// Abstract
- (int)flipCost
{
    return 0;
}

// Abstract
- (int)matchBonus
{
    return 1;
}

// Abstract
- (int)mismatchPenalty
{
    return 0;
}

// Abstract
- (NSAttributedString *)createMoveMessageWithCards:(NSAttributedString *)cards andPoints:(int)points
{
    return nil;
}

- (instancetype) initWithCardCount:(NSUInteger) count usingDeck:(Deck *) deck
{
    self = [super init];
    if (self) {
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (card) {
                [self.cards addObject:card];
            } else {
                self = nil;
                break;
            }
        }
    }
    return self;
}

- (NSMutableArray *)cards
{
    if (!_cards) {
        _cards = [[NSMutableArray alloc] init];
    }
    return _cards;
}

- (NSMutableArray *)gameHistory
{
    if (!_gameHistory) {
        _gameHistory = [[NSMutableArray alloc] init];
    }
    return _gameHistory;
}

- (NSMutableArray *)scoreHistory
{
    if (!_scoreHistory) {
        _scoreHistory = [[NSMutableArray alloc] init];
    }
    return _scoreHistory;
}

- (Card *) cardAtIndex:(NSInteger) index
{
    return ([self.cards count] > index) ? self.cards[index] : nil;
}

- (void) chooseCardAtIndex:(NSInteger) index
{
    Card *card = [self cardAtIndex:index];
    if (!card.isMatched) {
        if (card.isChosen) {
            card.chosen = false;
        } else {
            NSMutableArray *chosenCards = [[NSMutableArray alloc] init];
            for (Card *otherCard in self.cards) {
                if (otherCard.isChosen && !otherCard.isMatched) {
                    [chosenCards addObject:otherCard];
                }
            }
            
            self.score += [self flipCost];
            card.chosen = true;
            
            if (([chosenCards count] + 1) < [self numCardsForMatch]) {
                [self.gameHistory addObject:[[NSMutableArray alloc] initWithArray:@[card]]];
                [self.scoreHistory addObject:@([self flipCost])];
                return;
            }
            
            int points = [card match:chosenCards];
            if (points) {
                int matchPoints = points * [self matchBonus];
                self.score += matchPoints;
                for (Card *matched in chosenCards) {
                    matched.matched = true;
                }
                card.matched = true;
                [self.scoreHistory addObject:@(matchPoints)];
            } else {
                self.score += [self mismatchPenalty];
                for (Card *unmatched in chosenCards) {
                    unmatched.chosen = false;
                }
                [self.scoreHistory addObject:@([self mismatchPenalty])];
            }

            [chosenCards addObject:card];
            [self.gameHistory addObject:[[NSArray alloc] initWithArray:chosenCards]];
        }
    }
}
@end
