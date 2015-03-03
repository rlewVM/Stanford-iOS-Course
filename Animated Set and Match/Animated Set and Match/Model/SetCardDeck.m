//
//  SetCardDeck.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        for (NSUInteger shape = 0; shape < CardShapeLast; shape++) {
            for (NSUInteger count = 1; count <= [SetCard maxCount]; count++) {
                for (int shading = 0; shading < CardShadingLast; shading++) {
                    for (int color = 0; color < CardColorLast; color++) {
                        SetCard *card = [SetCard new];
                        card.shape = shape;
                        card.numberOfSymbols = count;
                        card.shading = shading;
                        card.color = color;
                        [self addCard:card];
                    }
                }
            }
        }
    }
    
    return self;
}

@end
