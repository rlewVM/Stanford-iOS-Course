//
//  CardMatchingGame.m
//  Card Game
//
//  Created by Rachel Lew on 2/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame ()

@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, readwrite) int score;
@property (nonatomic, readwrite) NSString *moveMessage;

@end

@implementation CardMatchingGame

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
            self.moveMessage = @"";
        } else {
            NSMutableArray *chosenCards = [[NSMutableArray alloc] init];
            for (Card *otherCard in self.cards) {
                if (otherCard.isChosen && !otherCard.isMatched) {
                    [chosenCards addObject:otherCard];
                }
            }
            
            self.score -= FLIP_COST;
            card.chosen = true;
            
            NSString *chosenContents = card.contents;
            
            // Match at least 3 cards
            if ((self.multiCardMatch && [chosenCards count] < 2) ||
                (!self.multiCardMatch && ![chosenCards count])) {
                self.moveMessage = chosenContents;
                return;
            }
            
            // Adding other cards to the list of chosen cards
            for (Card *chosenCard in chosenCards) {
                chosenContents = [chosenContents stringByAppendingString:[NSString stringWithFormat:@", %@", chosenCard.contents]];
            }
            
            int points = [card match:chosenCards];
            if (points) {
                int matchPoints = points * MATCH_BONUS;
                self.score += matchPoints;
                for (Card *matched in chosenCards) {
                    matched.matched = true;
                }
                card.matched = true;
                
                self.moveMessage = [NSString stringWithFormat:@"Matched %@ for %d points", chosenContents, matchPoints];
            } else if ([chosenCards count]){
                self.score -= MISMATCH_PENALTY;
                for (Card *unmatched in chosenCards) {
                    unmatched.chosen = false;
                }
                self.moveMessage = [NSString stringWithFormat:@"%@ don't match! %d point penalty!", chosenContents, MISMATCH_PENALTY];
            }

        }
    }
}

@end
