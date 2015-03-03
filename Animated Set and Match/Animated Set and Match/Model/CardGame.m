//
//  CardGame.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "CardGame.h"

@interface CardGame()

@property (nonatomic, readwrite, strong) NSMutableArray *cards;
@property (nonatomic, readwrite, strong) NSObject<CardGameConstants> *gameConstants;
@property (nonatomic, readwrite) int score;

@end

@implementation CardGame

- (instancetype) initWithCardCount:(NSUInteger) count usingDeck:(Deck *) deck andConstants:(NSObject<CardGameConstants> *)constants
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
        self.gameConstants = constants;
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

- (NSUInteger)dealNewCardsFromDeck:(Deck *)deck
{
    for (int i = 0; i < [self.gameConstants cardsPerDeal]; i++) {
        Card *card = [deck drawRandomCard];
        if (card) {
            [self.cards addObject:card];
        }
    }
    
    NSUInteger cardsInPlay = 0;
    for (Card *card in self.cards) {
        if (!card.isMatched) {
            cardsInPlay++;
        }
    }
    return cardsInPlay;
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
            
            self.score += [self.gameConstants flipCost];
            card.chosen = true;
            
            if (([chosenCards count] + 1) < [self.gameConstants numCardsForMatch]) {
                return;
            }
            
            int points = [card match:chosenCards];
            if (points) {
                int matchPoints = points * [self.gameConstants matchBonus];
                self.score += matchPoints;
                for (Card *matched in chosenCards) {
                    matched.matched = true;
                }
                card.matched = true;
            } else {
                self.score += [self.gameConstants mismatchPenalty];
                for (Card *unmatched in chosenCards) {
                    unmatched.chosen = false;
                }
            }
        }
    }
}
@end
