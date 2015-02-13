//
//  ViewController.m
//  SuperCard
//
//  Created by Rachel Lew on 2/11/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "ViewController.h"
#import "PlayingCardView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet PlayingCardView *cardView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Testing code
    self.cardView.suit = @"♥️";
    self.cardView.rank = 10;
    
    [self.cardView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.cardView
                                                                                  action:@selector(pinch:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swipe:(id)sender {
    self.cardView.faceup = !self.cardView.faceup;
}

@end
