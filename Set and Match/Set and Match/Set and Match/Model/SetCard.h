//
//  SetCard.h
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Card.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum CardShading {
    EMPTY = 0,
    STRIPED,
    FILLED,
    SHADE_COUNT
} CardShading;

@interface SetCard : Card

@property (strong, nonatomic) NSString *symbol;
@property (nonatomic) NSUInteger numberOfSymbols;
@property (nonatomic) enum CardShading shading;
@property (nonatomic, strong) UIColor *color;

+ (NSArray *)validSymbols;
+ (NSArray *)validColors;
+ (int)maxCount;

@end
