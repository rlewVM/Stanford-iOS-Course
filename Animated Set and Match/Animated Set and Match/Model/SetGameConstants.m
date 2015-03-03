//
//  SetGame.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "SetGame.h"

@implementation SetGame

- (int)numCardsForMatch
{
    return 3;
}

- (int)matchBonus
{
    return 10;
}

- (int)mismatchPenalty
{
    return -5;
}

@end
