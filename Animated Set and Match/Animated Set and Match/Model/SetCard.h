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

typedef NS_ENUM(NSUInteger, CardShading) {
    CardShadingEmpty = 0,
    CardShadingStriped,
    CardShadingFilled,
    CardShadingLast
};

typedef NS_ENUM(NSUInteger, CardColor) {
    CardColorBlue = 0,
    CardColorPurple,
    CardColorOrange,
    CardColorLast
};

typedef NS_ENUM(NSUInteger, CardShape) {
    CardShapeOval = 0,
    CardShapeDiamond,
    CardShapeSquiggle,
    CardShapeLast
};

@interface SetCard : Card

@property (nonatomic) enum CardShape shape;
@property (nonatomic) NSUInteger numberOfSymbols;
@property (nonatomic) enum CardShading shading;
@property (nonatomic) enum CardColor color;

+ (int)maxCount;

@end
