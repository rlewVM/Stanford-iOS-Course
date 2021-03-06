//
//  SetCard.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "SetCard.h"

@interface SetCard()

@end

@implementation SetCard

+ (int)maxCount
{
    return 3;
}

- (NSString *)contents
{
    return nil;
}

/**
 *  Matching SetCards is defined as all cards in the set having either all the same or all different
 *  attributes (color, shading, number of symbols, and type of symbol).
 */
- (int)match:(NSArray *)otherCards
{
    int points = 0;

    NSMutableSet *shapesFound = [[NSMutableSet alloc] initWithArray:@[@(self.shape)]];
    NSMutableSet *countsFound = [[NSMutableSet alloc] initWithArray:@[@(self.numberOfSymbols)]];
    NSMutableSet *shadingFound = [[NSMutableSet alloc] initWithArray:@[@(self.shading)]];
    NSMutableSet *colorsFound = [[NSMutableSet alloc] initWithArray:@[@(self.color)]];
    
    for (SetCard *card in otherCards) {
        [shapesFound addObject:@(card.shape)];
        [countsFound addObject:@(card.numberOfSymbols)];
        [shadingFound addObject:@(card.shading)];
        [colorsFound addObject:@(card.color)];
    }
    
    NSUInteger numCards = [otherCards count] + 1;
    NSUInteger numShapes = [shapesFound count];
    NSUInteger numSymbols = [countsFound count];
    NSUInteger numColors = [colorsFound count];
    NSUInteger numShadings = [shadingFound count];
    
    // Detecting that they are either all different or all the same
    if ((numShapes == numCards || numShapes == 1) &&
        (numSymbols == numCards || numSymbols == 1) &&
        (numShadings == numCards || numShadings == 1) &&
        (numColors == numCards || numColors == 1)) {
            points++;
        }
    
    return points;
}

@end
