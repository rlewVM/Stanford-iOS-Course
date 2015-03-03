//
//  ViewController.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "ViewController.h"
#import "Deck.h"
#import "Card.h"

@interface ViewController ()<UIDynamicAnimatorDelegate>

@property (strong, nonatomic, readwrite) Deck *cards;
@property (strong, nonatomic, readwrite) CardGame *game;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (weak, nonatomic) IBOutlet UIButton *dealButton;

@property (strong, nonatomic, readwrite) UIDynamicAnimator *animator;

- (void)setupNewGame;

/**
 *  Updates the entire view according to any changes in the data or user actions
 */
- (void)updateUI;

@end

@implementation ViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.cardGridView updateCardGridBounds];
}

- (void)viewDidLoad
{
    [self setupNewGame];
    [self.cardGridView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchToGather:)]];
    [self.cardGridView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResetDeckPosition:)]];
    for (CardView *view in self.cardGridView.subviews) {
        [view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToMoveDeck:)]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)setupNewGame
{
    self.game = nil;
    self.cards = nil;
    NSArray *subviews = self.cardGridView.subviews;
    for (UIView *view in subviews) {
        [view removeFromSuperview];
    }

    [self.animator removeAllBehaviors];
    [self initializeCardViewInGrid:self.game];
}

// Abstract
- (Deck *)createDeck
{
    return nil;
}

// Abstract
- (CardGame *)createGame
{
    return nil;
}

// Abstract
- (void)initializeCardViewInGrid:(CardGame *)game
{
}

// Abstract
- (CardView *)createSubviewWithCard:(Card *)card withTag:(NSUInteger)tag
{
    return nil;
}

- (BOOL)shouldFlipView:(CardView *)view withCard:(Card *)card
{
    return false;
}

#pragma mark - Setters and Getters
- (Deck *)cards
{
    if (!_cards) {
        _cards = [self createDeck];
    }
    return _cards;
}

- (CardGame *)game
{
    if (!_game) {
        _game = [self createGame];
    }
    return _game;
}

- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.cardGridView];
        _animator.delegate = self;
    }
    return _animator;
}

- (IBAction)touchDealButton:(id)sender
{
    self.cardGridView.cardCount = [self.game dealNewCardsFromDeck:self.cards];
    
    NSUInteger index = 0;
    Card *card = [self.game cardAtIndex:index];
    while (card != nil) {
        if (![self.cardGridView viewWithTag:index]) {
            UIView *view = [self createSubviewWithCard:card withTag:index];
            [self.cardGridView addSubview:view];
        }
        
        card = [self.game cardAtIndex:++index];
    }
    [self.cardGridView setNeedsDisplay];
}

- (IBAction)touchNewGame:(id)sender
{
    [UIView animateWithDuration:1.0
                     animations:^{
        for (CardView *view in self.cardGridView.subviews) {
            int x = self.cardGridView.center.x + arc4random()%20;
            int y = self.cardGridView.center.y + arc4random()%20;
            view.center = CGPointMake(x, y);
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0
                         animations:^{
             for (CardView *view in self.cardGridView.subviews) {
                 int x = self.cardGridView.bounds.size.width*2;
                 int y = view.center.y;
                 view.center = CGPointMake(x, y);
             }
        }
                         completion:^(BOOL finished) {
             [self setupNewGame];
             [self updateUI];
        }];
    }];
}

- (void)updateUI
{
    NSMutableArray *matchedCards = [NSMutableArray new];
    NSMutableArray *cardsToFlip = [NSMutableArray new];
    NSArray *subviews = self.cardGridView.subviews;
    for (CardView *subview in subviews) {
        Card *card = [self.game cardAtIndex:subview.tag];
        if ([self shouldFlipView:subview withCard:card]) {
            [cardsToFlip addObject:subview];
            subview.isFaceup = !subview.isFaceup;
        }
        subview.isChosen = card.isChosen;
        if (card.isMatched && !subview.isHidden) {
            [matchedCards addObject:subview];
        }
    }
    
    if ([cardsToFlip count]) {
        for (CardView *toFlip in cardsToFlip) {
            [UIView transitionWithView:toFlip
                              duration:0.7
                               options: toFlip.isChosen ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                            animations:^{
                                [toFlip setBackgroundColor:[UIColor clearColor]];
            } completion:^(BOOL finished) {
                if ([matchedCards count]) {
                    [self animateMatchedCardRemoval:matchedCards];
                }
            }];
        }
    } else if ([matchedCards count]) {
        [self animateMatchedCardRemoval:matchedCards];
    } else {
        [self.cardGridView setNeedsDisplay];
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

- (void)animateMatchedCardRemoval:(NSArray *)matchedCards
{
    [UIView animateWithDuration:1.0 animations:^{
        for (CardView *matched in matchedCards) {
            int x = (arc4random()%(int)(self.cardGridView.bounds.size.width*5)) - (int)self.cardGridView.bounds.size.width*2;
            int y = self.cardGridView.bounds.size.height;
            matched.center = CGPointMake(x, -y);
        }
    } completion:^(BOOL finished) {
        for (CardView *matched in matchedCards) {
            matched.hidden = YES;
        }
        self.cardGridView.cardCount = self.cardGridView.cardCount - [matchedCards count];
        [self.cardGridView setNeedsDisplay];
    }];
}

#pragma mark - Gesture Recognizers
- (void)pinchToGather:(UIPinchGestureRecognizer *)sender
{
    if ((sender.state == UIGestureRecognizerStateChanged) || (sender.state == UIGestureRecognizerStateEnded)) {
        CGPoint fingerOne = [sender locationOfTouch:0 inView:self.cardGridView];
        CGPoint fingerTwo = [sender locationOfTouch:1 inView:self.cardGridView];
        CGPoint pinchCenter = CGPointMake((fingerOne.x + fingerTwo.x) / 2.0, (fingerOne.y + fingerTwo.y) / 2.0);
        for (CardView *view in self.cardGridView.subviews) {
            [self.animator addBehavior:[[UISnapBehavior alloc] initWithItem:view snapToPoint:pinchCenter]];
        }
    }
}

- (void)tapToResetDeckPosition:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self updateUI];
    }
}

- (void)panToMoveDeck:(UIPanGestureRecognizer *)sender
{
}

- (void)tapToChoose:(UITapGestureRecognizer *)sender
{
    UIView *view = sender.view;
    if ([view isKindOfClass:[CardView class]]) {
        CardView *cardView = (CardView *)view;
        cardView.isChosen = !cardView.isChosen;
        [self.game chooseCardAtIndex:view.tag];
    }
    [self updateUI];
}

@end
