//
//  ViewController.m
//  Card Game
//
//  Created by Rachel Lew on 2/2/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "ViewController.h"
#import "Deck.h"
#import "PlayingCardDeck.h"
#import "Card.h"
#import "CardMatchingGame.h"

@interface ViewController ()
// NOTE: The view holds this strongly so we don't need to put strong here
@property (strong, nonatomic) Deck *cards;
@property (strong, nonatomic) CardMatchingGame *game;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *gameCards;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *startGameButton;
@property (weak, nonatomic) IBOutlet UISwitch *threeCardMatchSwitch;
@property (weak, nonatomic) IBOutlet UITextView *moveLabel;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (Deck *)cards
{
    if (!_cards) {
        _cards = [self createDeck];
    }
    return _cards;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

- (CardMatchingGame *)game
{
    if (!_game) {
        _game = [[CardMatchingGame alloc] initWithCardCount:[self.gameCards count] usingDeck:[self createDeck]];
    }
    return _game;
}

- (IBAction)touchCardButton:(UIButton *)sender
{
    // Lock in the selection
    self.threeCardMatchSwitch.enabled = false;

    NSUInteger index = [self.gameCards indexOfObject:sender];
    [self.game chooseCardAtIndex:index];
    [self updateUI];
}

- (IBAction)touchNewGame:(id)sender {
    self.game = nil;
    self.game.multiCardMatch = self.threeCardMatchSwitch.isOn;
    self.threeCardMatchSwitch.enabled = true;
    [self updateUI];
}

- (IBAction)toggleThreeCardMatch:(id)sender {
    self.game.multiCardMatch = !self.game.multiCardMatch;
}

- (void)updateUI
{
    self.moveLabel.text = self.game.moveMessage;
    for (UIButton *button in self.gameCards) {
        NSUInteger index = [self.gameCards indexOfObject:button];
        Card *card = [self.game cardAtIndex:index];
        if (card.isChosen) {
            [button setTitle:card.contents forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"cardfront"] forState:UIControlStateNormal];
        } else {
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"cardback"] forState:UIControlStateNormal];
        }
        button.enabled = !card.isMatched;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];
}

@end
