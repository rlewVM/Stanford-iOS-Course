//
//  PlayingCard.h
//  Card Game
//
//  Created by Rachel Lew on 2/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#ifndef Card_Game_PlayingCard_h
#define Card_Game_PlayingCard_h

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;

@end

#endif
