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
#import "HistoryViewController.h"

@interface ViewController ()

@property (strong, nonatomic) Deck *cards;
@property (strong, nonatomic) CardGame *game;
@property (strong, nonatomic) NSMutableArray *gameHistory;  // NSAttributedString

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *gameCards;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (weak, nonatomic) IBOutlet UILabel *moveLabel;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUI];
}

// Abstract
- (Deck *)createDeck
{
    return nil;
}

// Abstract
- (CardGame *)createGameWithCardCount:(NSInteger)count
{
    return nil;
}

// Abstract
- (void)updateButtonAppearance:(UIButton *)button whenCardSelected:(Card *)card
{
}

// Abstract
- (void)updateButtonAppearance:(UIButton *)button whenCardUnselected:(Card *)card
{
}

- (NSAttributedString *)cardToAttributedString:(Card *)card
{
    return [[NSAttributedString alloc] initWithString:card.contents];
}

- (NSAttributedString *)createMoveMessageForCards:(NSArray *)cards andPoints:(int)points
{
    NSMutableAttributedString *message = [[NSMutableAttributedString alloc] init];
    Card *lastChosenCard = [cards lastObject];
    
    if ([cards count] < [self.game numCardsForMatch]) {
        if (lastChosenCard.isChosen) {
            [message appendAttributedString:[self cardToAttributedString:lastChosenCard]];
        }
    } else {
        for (Card *card in cards) {
            [message appendAttributedString:[self cardToAttributedString:card]];
            if (![card isEqual:lastChosenCard]) {
                [message appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
            }
        }
        if (points > 0) {
            [message appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" are a match! %d points.", points]]];
        } else {
            [message appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" are not a match. %d points penalty!", points]]];
        }
        if ([message.string length]) {
            [self.gameHistory addObject:message];
        }
    }
    // Question: Is it okay to return an mutable copy here?
    return message;
}

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
        _game = [self createGameWithCardCount:[self.gameCards count]];
    }
    return _game;
}

- (NSMutableArray *)gameHistory
{
    if (!_gameHistory) {
        _gameHistory = [[NSMutableArray alloc] init];
    }
    return _gameHistory;
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    NSUInteger index = [self.gameCards indexOfObject:sender];
    [self.game chooseCardAtIndex:index];
    [self updateUI];
    self.moveLabel.attributedText = [self createMoveMessageForCards:self.game.cardsChosenThisTurn andPoints:self.game.roundPoints];
}

- (IBAction)touchNewGame:(id)sender {
    self.game = nil;
    self.gameHistory = nil;
    [self updateUI];
    self.moveLabel.attributedText = [[NSAttributedString alloc] initWithString:@""];
}

- (void)updateUI
{
    for (UIButton *button in self.gameCards) {
        NSUInteger index = [self.gameCards indexOfObject:button];
        Card *card = [self.game cardAtIndex:index];
        if (card.isChosen) {
            [self updateButtonAppearance:button whenCardSelected:card];
        } else {
            [self updateButtonAppearance:button whenCardUnselected:card];
        }
        button.enabled = !card.isMatched;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewController *destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HistoryViewController class]]) {
        HistoryViewController *historyVC = (HistoryViewController *)destVC;
        historyVC.moveList = self.gameHistory;
    }
}

@end
