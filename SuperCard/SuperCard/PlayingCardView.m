//
//  PlayingCardView.m
//  SuperCard
//
//  Created by Rachel Lew on 2/11/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "PlayingCardView.h"

@interface PlayingCardView()

@property (nonatomic) CGFloat faceCardScaleFactor;

@end

@implementation PlayingCardView

// Telling the system to redraw if any fundamental defining aspects of the card change
- (void)setSuit:(NSString *)suit
{
    _suit = suit;
    [self setNeedsDisplay];
}

- (void)setRank:(NSUInteger)rank
{
    _rank = rank;
    [self setNeedsDisplay];
}

- (void)setFaceup:(BOOL)faceup
{
    _faceup = faceup;
    [self setNeedsDisplay];
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded)) {
        self.faceCardScaleFactor *= gesture.scale;
        // reset the baseline for this so that it doesn't get magnified each time (smoothing)
        gesture.scale = 1.0;
    }
}

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

- (NSString *)rankAsString
{
    return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"][self.rank];
}

#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.90
@synthesize faceCardScaleFactor = _faceCardScaleFactor;
- (CGFloat)faceCardScaleFactor
{
    if (!_faceCardScaleFactor) {
        _faceCardScaleFactor = DEFAULT_FACE_CARD_SCALE_FACTOR;
    }
    return _faceCardScaleFactor;
}

- (void)setFaceCardScaleFactor:(CGFloat)faceCardScaleFactor
{
    _faceCardScaleFactor = faceCardScaleFactor;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii: [self cornerRadii]];
    
    // Don't ever draw outside rectangle
    [roundedRect addClip];
    
    [[UIColor whiteColor] setFill];
    // Shorthand for drawing the rectangle
    UIRectFill(self.bounds);
    
    [[UIColor blackColor] setStroke];
    [roundedRect stroke];
    
    if (self.faceup) {
        // Images must be named the same as their suit / rank
        UIImage *faceImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", [self rankAsString], self.suit]];
        if (faceImage) {
            // Draws image for things like King and Queen when there is one (scaled)
            CGRect imageRect = CGRectInset(self.bounds, self.bounds.size.width * (1.0 - self.faceCardScaleFactor), self.bounds.size.height * (1.0 - self.faceCardScaleFactor));
            [faceImage drawInRect:imageRect];
        } else {
            [self drawPips];
        }
        [self drawCorners];
    } else {
        [[UIImage imageNamed:@"cardback"] drawInRect:self.bounds];
    }
}

// Draw the center of the cards for non face cards
- (void)drawPips
{
    
}

- (void)drawCorners
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    UIFont *cornerFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cornerFont = [cornerFont fontWithSize:cornerFont.pointSize * [self cornerScaleFactor]];
    
    NSAttributedString *cornerText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", [self rankAsString], self.suit] attributes:@{ NSFontAttributeName : cornerFont, NSParagraphStyleAttributeName : paragraphStyle }];
    
    CGRect textBounds;
    textBounds.origin = CGPointMake([self cornerOffset], [self cornerOffset]);
    textBounds.size = cornerText.size;
    [cornerText drawInRect:textBounds];

    // Context is what we just drew
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
    CGContextRotateCTM(context, M_PI);
    
    [cornerText drawInRect:textBounds];
}

// Pragma creates a named "jump to" point in your code
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

@end
