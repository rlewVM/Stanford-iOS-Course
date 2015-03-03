//
//  Card.h
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property (strong, nonatomic) NSString *contents;
@property (nonatomic, getter=isChosen) BOOL chosen;
@property (nonatomic, getter=isMatched) BOOL matched;

/**
 *  Matches this card against a list of other cards and returns the points earned for this match.
 *  This should be overridden by subclasses for card specific matching algorithms.
 */
- (int) match:(NSArray*) otherCards;

@end
