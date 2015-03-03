//
//  CardView.h
//  Animated Set and Match
//
//  Created by Rachel Lew on 2/17/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"

@interface CardView : UIView

- (instancetype)initWithCard:(Card *)card;

@property (nonatomic, readwrite) BOOL isFaceup;
@property (nonatomic, readwrite) BOOL isChosen;

- (CGFloat)cornerScaleFactor;
- (CGFloat)cornerRadius;
- (CGSize)cornerRadii;
- (CGFloat)cornerOffset;


@end
