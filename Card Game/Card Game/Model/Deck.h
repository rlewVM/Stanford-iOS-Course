//
//  Deck.h
//  Card Game
//
//  Created by Rachel Lew on 2/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#ifndef Card_Game_Deck_h
#define Card_Game_Deck_h

#import "Card.h"

@interface Deck : NSObject

// NOTE: this is NOT method overloading. Methods are completely separate in objective-c
-(void) addCard:(Card*) card atTop:(BOOL)atTop;
-(void) addCard:(Card*) card;
-(Card*)drawRandomCard;

@end

#endif
