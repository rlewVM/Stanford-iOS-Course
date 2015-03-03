//
//  CardGameGridView.h
//  Animated Set and Match
//
//  Created by Rachel Lew on 2/17/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"

@interface CardGameGridView : UIView

@property (nonatomic, readwrite) NSUInteger cardCount;
@property (nonatomic, readwrite) CGFloat aspectRatio;

- (void)updateCardGridBounds;

@end
