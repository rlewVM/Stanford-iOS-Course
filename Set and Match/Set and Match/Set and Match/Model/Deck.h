//
//  Deck.h
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

/**
 *  Adds a card to the the overall deck either at the beginning or the end of the deck according to the atTop param.
 */
-(void) addCard:(Card*) card atTop:(BOOL)atTop;
-(void) addCard:(Card*) card;

/**
 *  Draws a random card from the deck. This means actually removing the card from the deck so
 *  it cannot be drawn again.
 */
-(Card*)drawRandomCard;

@end
