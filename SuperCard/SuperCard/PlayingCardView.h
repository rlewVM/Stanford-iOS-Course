//
//  PlayingCardView.h
//  SuperCard
//
//  Created by Rachel Lew on 2/11/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayingCardView : UIView

@property (nonatomic) NSUInteger rank;
@property (nonatomic, strong) NSString *suit;
@property (nonatomic) BOOL faceup;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;

@end
