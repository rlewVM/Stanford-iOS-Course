//
//  ViewController.h
//  Set and Match
//  Generic card game view controller that handles UI updates and
//  deck and game creation. This is an abstract class that should
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardGame.h"
#import "CardGameGridView.h"

@interface ViewController : UIViewController

/**
 */
@property (strong, nonatomic) IBOutlet CardGameGridView *cardGridView;
@property (strong, nonatomic, readonly) Deck *cards;

@property (strong, nonatomic, readonly) UIDynamicAnimator *animator;

/**
 *  Creates the deck of cards specific to the game being played.
 */
- (Deck *)createDeck;
/**
 *  Initializes the game and the deck according to the number of cards that will be used to play.
 *
 */
- (CardGame *)createGame;

- (void)initializeCardViewInGrid:(CardGame *)game;

- (CardView *)createSubviewWithCard:(Card *)card withTag:(NSUInteger)tag;

- (void)pinchToGather:(UIPinchGestureRecognizer *)sender;
- (void)tapToResetDeckPosition:(UITapGestureRecognizer *)sender;
- (void)panToMoveDeck:(UIPanGestureRecognizer *)sender;

- (void)tapToChoose:(UITapGestureRecognizer *)sender;

- (BOOL)shouldFlipView:(CardView *)view withCard:(Card *)card;

@end

