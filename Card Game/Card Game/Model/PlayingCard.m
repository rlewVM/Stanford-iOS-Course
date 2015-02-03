//
//  PlayingCard.m
//  Card Game
//
//  Created by Rachel Lew on 2/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PlayingCard.h"

@interface PlayingCard()
@end

@implementation PlayingCard

// QUESTION: Can you make the @"?" into a constant in the header? Is that good form?
+ (NSArray *)rankStrings
{
    return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"];
}

- (NSString *)contents
{
    return [[PlayingCard rankStrings][self.rank] stringByAppendingString:self.suit];
}

// QUESTION: why can you use self or PlayingCard here in calling the class method? What should you use?
+ (NSUInteger)maxRank
{
    return [[PlayingCard rankStrings] count] - 1;
}

+ (NSArray *)validSuits
{
    return @[@"♥︎", @"♦︎", @"♣︎", @"♠︎"];
}

// REMEMBER: when you override the setter AND the getter, you have to do the "@synthesize" yourself
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

@end