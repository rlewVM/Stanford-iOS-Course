//
//  Card.h
//  Card Game
//
//  Created by Rachel Lew on 2/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#ifndef Card_Game_Card_h
#define Card_Game_Card_h

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property (strong, nonatomic) NSString* contents;
@property (nonatomic, getter=isChosen) BOOL chosen;
@property (nonatomic, getter=isMatched) BOOL matched;

- (int) match:(NSArray*) otherCards;

@end

#endif

