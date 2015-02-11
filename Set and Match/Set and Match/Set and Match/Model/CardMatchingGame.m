//
//  CardMatchingGame.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "CardMatchingGame.h"

@implementation CardMatchingGame

- (int)numCardsForMatch
{
    return 2;
}

- (int)flipCost
{
    return -1;
}

- (int)matchBonus
{
    return 4;
}

- (int)mismatchPenalty
{
    return -1;
}

@end
