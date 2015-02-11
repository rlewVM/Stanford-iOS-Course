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

@interface ViewController : UIViewController

/**
 *  Creates the deck of cards specific to the game being played.
 *
 *  NOTE: This is an ABSTRACT method and should be overridden by subclasses.
 */
- (Deck *)createDeck;
/**
 *  Initializes the game and the deck according to the number of cards that will be used to play.
 *
 *  NOTE: This is an ABSTRACT method and should be overridden by subclasses.
 */
- (CardGame *)createGameWithCardCount:(NSInteger)count;

/**
 *  These two methods update the appearance of a given button that represents a given card. One
 *  changes the appearance of the button to make it look selected while the other changes it to
 *  look unselected.
 *
 *  NOTE: These are ABSTRACT methods and should be overridden by subclasses.
 */
- (void)updateButtonAppearance:(UIButton *)button whenCardSelected:(Card *)card;
- (void)updateButtonAppearance:(UIButton *)button whenCardUnselected:(Card *)card;

/**
 *  Returns the NSAttributedString representing the text to display for a given card. If this method
 *  not overridden by a subclass, it will return the contents of the card with no additional styling.
 */
- (NSAttributedString *)cardToAttributedString:(Card *)card;

/**
 *  Creates a NSAttributedString describing the move that was made in the current game. The NSArray 
 *  should be an array of Card objects and the points should be the points earned in that turn.
 */
- (NSAttributedString *)createMoveMessageForCards:(NSArray *)cards andPoints:(int)points;

@end

