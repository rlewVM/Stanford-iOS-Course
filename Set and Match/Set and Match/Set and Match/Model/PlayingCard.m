//
//  PlayingCard.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

+ (NSArray *)rankStrings
{
    return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"];
}

- (NSString *)contents
{
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

+ (NSUInteger)maxRank
{
    return [[PlayingCard rankStrings] count] - 1;
}

+ (NSArray *)validSuits
{
    return @[@"♥️", @"♦️", @"♣️", @"♠️"];
}

@synthesize suit = _suit;
- (void)setSuit:(NSString *)suit
{
    if ([[PlayingCard validSuits] containsObject:suit]) {
        _suit = suit;
    }
}

- (NSString *)suit
{
    return _suit ? _suit : @"?";
}

/**
 *  Matching with playing cards is defined as having either the same suit or the same rank
 *  as one or more of the other cards. Points are rewarded based on how many of the cards match
 *  and more points are rewarded based on matching rank than suit.
 */
- (int)match:(NSArray *)otherCards
{
    int points = 0;
    
    NSMutableSet *suitsFound = [[NSMutableSet alloc] init];
    [suitsFound addObject:self.suit];
    NSMutableSet *ranksFound = [[NSMutableSet alloc] init];
    [ranksFound addObject:@(self.rank)];
    
    for (PlayingCard *card in otherCards) {
        [suitsFound addObject:card.suit];
        [ranksFound addObject:@(card.rank)];
    }
    
    NSUInteger matchedSuits = ([otherCards count] + 1) - [suitsFound count];
    if (matchedSuits > 0) {
        points += matchedSuits;
    }
    NSUInteger matchedRank = ([otherCards count] + 1) - [ranksFound count];
    if (matchedRank > 0) {
        points += matchedRank * 4;
    }
    return points;
}

@end
