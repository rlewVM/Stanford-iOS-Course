//
//  CardView.m
//  Animated Set and Match
//
//  Created by Rachel Lew on 2/17/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "CardView.h"

@interface CardView()

//@property (nonatomic, strong) center;
//@property (nonatomic, strong) corner;
//@property (nonatomic, strong) back;

@end

@implementation CardView

#pragma mark - Initialization
- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCard:(Card *)card
{
    self = [super init];
    if (self) {
        self.isChosen = card.isChosen;
        self.hidden = card.isMatched;
        self.isFaceup = card.isChosen;
    }
    return self;
}

#pragma mark - Setters and Getters
- (void)setIsChosen:(BOOL)isChosen
{
    _isChosen = isChosen;
    [self setNeedsDisplay];
}

- (void)setIsFaceup:(BOOL)isFaceup
{
    _isFaceup = isFaceup;
    [self setNeedsDisplay];
}

#pragma mark - Helper Methods
#define CORNER_FONT_STANDARD_HEIGHT 180.0
#define CORNER_RADIUS 12.0
- (CGFloat)cornerScaleFactor
{
    return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT;
}

- (CGFloat)cornerRadius
{
    return CORNER_RADIUS * [self cornerScaleFactor];
}

- (CGSize)cornerRadii
{
    return CGSizeMake([self cornerRadius], [self cornerRadius]);
}

- (CGFloat)cornerOffset
{
    return ([self cornerRadius] / 3.0);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii: [self cornerRadii]];
    
    [roundedRect moveToPoint:CGPointMake(self.bounds.origin.x, self.bounds.origin.y)];
    
    // Don't ever draw outside rectangle
    [roundedRect addClip];
    
    if (self.isFaceup && !self.isChosen) {
        [[UIColor whiteColor] setFill];
    } else if (self.isChosen) {
        [[[UIColor whiteColor] colorWithAlphaComponent:0.5] setFill];
    } else {
        [[UIColor clearColor] setFill];
    }
    UIRectFill(self.bounds);

    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
}

@end
