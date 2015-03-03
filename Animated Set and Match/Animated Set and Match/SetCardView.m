//
//  SetCardView.m
//  Animated Set and Match
//
//  Created by Rachel Lew on 2/18/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "SetCardView.h"
#import "SetCard.h"

@interface SetCardView()

@property (nonatomic, readwrite) CardShading shading;
@property (nonatomic, readwrite) CardColor shapeColor;
@property (nonatomic, readwrite) CardShape shape;
@property (nonatomic, readwrite) NSUInteger shapeCount;

@end

@implementation SetCardView

- (instancetype)initWithCard:(Card *)card
{
    self = [super init];
    if (self) {
        self.isFaceup = YES;
        if ([card isKindOfClass:[SetCard class]]) {
            SetCard *setCard = (SetCard *)card;
            self.shading = setCard.shading;
            self.shapeColor = setCard.color;
            self.shapeCount = setCard.numberOfSymbols;
            self.shape = setCard.shape;
        }
    }
    return self;
}

- (BOOL)isFaceup
{
    return true;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // Draw shapes
    UIBezierPath *shapePath = [UIBezierPath new];
    UIColor *color;
    if (self.shapeColor == CardColorBlue) {
        color = [UIColor blueColor];
    } else if (self.shapeColor == CardColorOrange) {
        color = [UIColor orangeColor];
    } else {
        color = [UIColor purpleColor];
    }
    [color setStroke];
    
    [[UIColor clearColor] setFill];
    if (self.shading == CardShadingFilled) {
        [color setFill];
    }
    
    NSUInteger sideLen = MIN(self.bounds.size.width / 4, self.bounds.size.height / 4);
    
    if (self.shape == CardShapeDiamond) {
        for (NSUInteger i = 1; i <= self.shapeCount; i++) {
            CGPoint startingPoint = [self calculateStartingPointForNthSymbol:i];
            [self drawDiamond:shapePath
                 atPoint:startingPoint
             withSideLen:sideLen];
        }
    } else if (self.shape == CardShapeOval) {
        for (NSUInteger i = 1; i <= self.shapeCount; i++) {
            CGPoint startingPoint = [self calculateStartingPointForNthSymbol:i];
            UIBezierPath *curPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(startingPoint.x, startingPoint.y,  sideLen, sideLen * 2) byRoundingCorners:UIRectCornerAllCorners cornerRadii: CGSizeMake(20.0, 20.0)];
            [shapePath appendPath:curPath];
        }
    } else {
        for (NSUInteger i = 1; i <= self.shapeCount; i++) {
            CGPoint startingPoint = [self calculateStartingPointForNthSymbol:i];
            [self drawSquiggle:shapePath
                   atPoint:startingPoint
            withShapeWidth:sideLen];
        }
    }
    if (self.shading == CardShadingStriped) {
        [self addStripes:shapePath];
    }
    [shapePath stroke];
    [shapePath fill];
}

// NOTE: currently this is f'd. But math is hard.
- (CGPoint)calculateStartingPointForNthSymbol:(NSUInteger)symbolNum
{
    CGPoint centerOfCard = CGPointMake((self.bounds.size.width / 2), (self.bounds.size.height / 2));
    NSUInteger sideLen = MIN(self.bounds.size.width / 4, self.bounds.size.height / 4);
    CGFloat centerX = self.shape == CardShapeOval ? centerOfCard.x - sideLen / 2 : centerOfCard.x;
    CGPoint startingPoint = CGPointMake(centerX, (centerOfCard.y - sideLen));
    
    if (self.shapeCount % 2 != 0) {
        // middle symbol
        if (self.shapeCount / 2 + 1 != symbolNum) {
            CGFloat xOffset = symbolNum - ceilf((float)self.shapeCount / 2.0);
            xOffset = xOffset * sideLen * 1.5;
            return CGPointMake(startingPoint.x + xOffset, startingPoint.y);
        }
    } else {
        CGFloat xOffset = symbolNum - (self.shapeCount / 2.0) - 0.5;
        xOffset = xOffset * sideLen * 1.5;
        return CGPointMake(startingPoint.x + xOffset, startingPoint.y);
    }
    return startingPoint;
}

- (void)addStripes:(UIBezierPath *)shapeOutline
{
    CGRect bounds = shapeOutline.bounds;
    UIBezierPath *stripes = [UIBezierPath bezierPath];
    for (int x = 0; x < bounds.size.width; x += 3) {
        [stripes moveToPoint:CGPointMake(bounds.origin.x + x, bounds.origin.y)];
        [stripes addLineToPoint:CGPointMake(bounds.origin.x + x, bounds.origin.y + bounds.size.height)];
    }
    
    [shapeOutline addClip];
    [stripes stroke];
}

- (void)drawDiamond:(UIBezierPath *)path
           atPoint:(CGPoint)startingPoint
       withSideLen:(NSUInteger)shapeWidth
{
    [path moveToPoint:startingPoint];
    [path addLineToPoint:CGPointMake((startingPoint.x + shapeWidth / 2), startingPoint.y + shapeWidth)];
    [path addLineToPoint:CGPointMake(startingPoint.x, (startingPoint.y + shapeWidth * 2))];
    [path addLineToPoint:CGPointMake(startingPoint.x - shapeWidth / 2, (startingPoint.y + shapeWidth))];
    [path addLineToPoint:startingPoint];
}

- (void)drawSquiggle:(UIBezierPath *)path
         atPoint:(CGPoint)startingPoint
  withShapeWidth:(NSUInteger)shapeWidth
{
    [path moveToPoint:startingPoint];
    [path addCurveToPoint:CGPointMake(startingPoint.x, startingPoint.y + shapeWidth * 2)
            controlPoint1:CGPointMake(startingPoint.x + shapeWidth, startingPoint.y + shapeWidth)
            controlPoint2:CGPointMake(startingPoint.x - shapeWidth / 2.0, startingPoint.y + shapeWidth)];
    [path addCurveToPoint:startingPoint
            controlPoint1:CGPointMake(startingPoint.x - shapeWidth, startingPoint.y + shapeWidth)
            controlPoint2:CGPointMake(startingPoint.x, startingPoint.y + shapeWidth)];
}

@end
