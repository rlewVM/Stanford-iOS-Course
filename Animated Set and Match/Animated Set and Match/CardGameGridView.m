//
//  CardGameGridView.m
//  Animated Set and Match
//
//  Created by Rachel Lew on 2/17/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "CardGameGridView.h"
#import "Grid.h"

@interface CardGameGridView()

@property (nonatomic, strong, readwrite) Grid *cardGrid;

@end

@implementation CardGameGridView
#pragma mark - Initialization
- (void)setup
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    self.autoresizesSubviews = YES;
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

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    NSArray *subviews = self.subviews;
    for (UIView *view in subviews) {
        [view setNeedsDisplay];
    }
}

#pragma mark - Setters and Getters
- (CGFloat) aspectRatio
{
    if (_aspectRatio) {
        return _aspectRatio;
    }
    return 40.0 / 60.0;
}

@synthesize cardCount = _cardCount;
- (NSUInteger) cardCount
{
    if (_cardCount) {
        return _cardCount;
    }
    return 30;
}

- (void) setCardCount:(NSUInteger)cardCount
{
    _cardCount = cardCount;
    _cardGrid.minimumNumberOfCells = cardCount;
}

- (void)updateCardGridBounds
{
    self.cardGrid = nil;
    [self setNeedsDisplay];
}

- (Grid *)cardGrid
{
    if (!_cardGrid) {
        _cardGrid = [Grid new];
        _cardGrid.size = self.bounds.size;
        _cardGrid.cellAspectRatio = self.aspectRatio;
        _cardGrid.minimumNumberOfCells = self.cardCount;
    }
    return _cardGrid;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIBezierPath *grid = [UIBezierPath bezierPathWithRect:self.bounds];
    [grid addClip];
    NSArray *subviews = [self subviews];
    int visibleViewCount = 0;
    __block int dealDelay = 1.0;
    for (int i = 0; i < [subviews count]; i++) {
        CardView *view = subviews[i];
        if (!view.isHidden) {
            int row = (visibleViewCount / [self.cardGrid columnCount]);
            int col = (visibleViewCount % [self.cardGrid columnCount]);
            CGRect cardRect = [self.cardGrid frameOfCellAtRow:row inColumn: col];
            
            // For views that are appearing for the first time, bring them in with animation
            BOOL notCurrentlyDrawn = (view.frame.size.width == 0 && view.frame.size.height == 0);
            BOOL movedFromCurrentFrame = abs(view.frame.origin.x - cardRect.origin.x) > 1 || abs(view.frame.origin.y - cardRect.origin.y) > 1;
            if (notCurrentlyDrawn || movedFromCurrentFrame) {
                if (notCurrentlyDrawn) {
                    view.frame = CGRectMake(self.bounds.size.width / 2.0, self.bounds.size.height - view.bounds.size.height / 2.0, view.bounds.size.width, view.bounds.size.height);
                }
                [UIView animateWithDuration:0.5 delay:dealDelay / 10.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    view.frame = cardRect;
                } completion:^(BOOL finished) {
                    [view setNeedsDisplay];
                }];
                dealDelay++;
            } else {
                view.frame = cardRect;
                [view setNeedsDisplay];
            }

            visibleViewCount++;
        }
    }
}

@end
