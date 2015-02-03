//
//  Card.m
//  Card Game
//
//  Created by Rachel Lew on 2/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Card.h"

@interface Card()
@end

@implementation Card

-(int)match:(NSArray *)otherCards
{
    int score = 0;
    
    for (Card* card in otherCards) {
        if ([card.contents isEqualToString:self.contents]) {
            score++;
        }
    }
    return score;
}

@end