//
//  ViewController.m
//  Bouncer
//
//  Created by Rachel Lew on 3/13/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@property (nonatomic, weak) UIView *redBlock;
@property (nonatomic, weak) UIView *blackBlock;
@property (nonatomic, weak) UIGravityBehavior *gravity;
@property (nonatomic, weak) UICollisionBehavior *collider;
@property (nonatomic, weak) UIDynamicItemBehavior *elastic;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startGame];
}

static CGSize blockSize = { 40, 40 };
- (UIView *)addBlockOffsetCenterBy:(UIOffset)offset
{
    CGPoint blockCenter = CGPointMake(self.view.center.x + offset.horizontal, self.view.center.y + offset.vertical);
    CGRect blockFrame = CGRectMake(blockCenter.x - blockSize.width/2.0, blockCenter.y - blockSize.height/2.0, blockSize.width, blockSize.height);
    UIView *blockView = [[UIView alloc] initWithFrame:blockFrame];
    [self.view addSubview:blockView];
    return blockView;
}

- (void)startGame
{
    self.redBlock = [self addBlockOffsetCenterBy:UIOffsetZero];
    self.redBlock.backgroundColor = [UIColor redColor];
    [self.collider addItem:self.redBlock];
    [self.gravity addItem:self.redBlock];
    [self.elastic addItem:self.redBlock];

    self.blackBlock = [self addBlockOffsetCenterBy:UIOffsetZero];
    self.blackBlock.backgroundColor = [UIColor blackColor];
    [self.collider addItem:self.blackBlock];
    
    if (!self.motionManager.isAccelerometerActive) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            CGFloat x = accelerometerData.acceleration.x;
            CGFloat y = accelerometerData.acceleration.y;

            UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
            switch (orientation) {
                case UIDeviceOrientationPortraitUpsideDown:
                    [self.gravity setGravityDirection:CGVectorMake(-x, y)];
                    break;
                case UIDeviceOrientationLandscapeLeft:
                    [self.gravity setGravityDirection:CGVectorMake(y, x)];
                    break;
                case UIDeviceOrientationLandscapeRight:
                    [self.gravity setGravityDirection:CGVectorMake(-y, -x)];
                    break;
                default:
                    [self.gravity setGravityDirection:CGVectorMake(x, y)];
                    break;
            }
        }];
    }
}

- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        self.animator = animator;
    }
    return _animator;
}

- (UIGravityBehavior *)gravity
{
    if (!_gravity) {
        UIGravityBehavior *gravity = [UIGravityBehavior new];
        [self.animator addBehavior:gravity];
        self.gravity = gravity;
    }
    return _gravity;
}

- (UICollisionBehavior *)collider
{
    if (!_collider) {
        UICollisionBehavior *collider = [UICollisionBehavior new];
        collider.translatesReferenceBoundsIntoBoundary = YES;
        [self.animator addBehavior:collider];
        self.collider = collider;
    }
    return _collider;
}

- (UIDynamicItemBehavior *)elastic
{
    if (!_elastic) {
        UIDynamicItemBehavior *elastic = [UIDynamicItemBehavior new];
        elastic.elasticity = 1.0;
        [self.animator addBehavior:elastic];
        self.elastic = elastic;
    }
    return _elastic;
}

- (CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [CMMotionManager new];
        _motionManager.accelerometerUpdateInterval = 0.1;
    }
    return _motionManager;
}

@end
