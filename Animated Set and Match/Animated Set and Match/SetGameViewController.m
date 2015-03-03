//
//  SetGameViewController.m
//  Set and Match
//
//  Created by Rachel Lew on 2/9/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "SetGameViewController.h"
#import "SetCard.h"

@interface SetGameViewController ()

/**
 *  Returns a map of style attributes for a SetCard based on its shading and color.
 */
- (NSDictionary *)cardAttributes:(SetCard *)card;

@end

@implementation SetGameViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (Deck *)createDeck
{
    return [[SetCardDeck alloc] init];
}

- (CardGame *)createGameWithCardCount:(NSInteger)count
{
    return [[SetGame alloc] initWithCardCount:count usingDeck:[self createDeck]];
}

- (void)updateButtonAppearance:(UIButton *)button whenCardSelected:(Card *)card
{
    [button setAttributedTitle:[self cardToAttributedString:card] forState:UIControlStateNormal];
    [button setBackgroundColor:[button.backgroundColor colorWithAlphaComponent:.7]];
}

- (void)updateButtonAppearance:(UIButton *)button whenCardUnselected:(Card *)card
{
    [button setAttributedTitle:[self cardToAttributedString:card] forState:UIControlStateNormal];
    [button setBackgroundColor:[button.backgroundColor colorWithAlphaComponent:1]];
}

- (NSDictionary *)cardAttributes:(SetCard *)card
{
    UIColor *cardColor;
    UIColor *fillColor;
    
    if (card.color == CardColorBlue) {
        cardColor = [UIColor blueColor];
    } else if (card.color == CardColorOrange) {
        cardColor = [UIColor orangeColor];
    } else {
        cardColor = [UIColor purpleColor];
    }
    
    fillColor = (card.shading == CardShadingStriped) ? [cardColor colorWithAlphaComponent:.2] : cardColor;
    NSNumber *strokeWidth = (card.shading == CardShadingEmpty) ? @5 : @-5;
        
    return @{NSForegroundColorAttributeName : fillColor, NSStrokeColorAttributeName : cardColor, NSStrokeWidthAttributeName : strokeWidth};
}

- (NSAttributedString *)cardToAttributedString:(Card *)card
{
    if (![card isKindOfClass:[SetCard class]]) {
        return nil;
    }
    SetCard *setCard = (SetCard *)card;
    NSString *c = [[NSString alloc] initWithString:setCard.symbol];
    for (int i = 1; i < setCard.numberOfSymbols; i++) {
        c = [c stringByAppendingString:setCard.symbol];
    }
    
    return [[NSAttributedString alloc] initWithString:c attributes:[self cardAttributes:setCard]];
}

@end
