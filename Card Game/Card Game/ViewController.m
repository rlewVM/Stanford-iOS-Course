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

@interface ViewController ()
// NOTE: The view holds this strongly so we don't need to put strong here
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (nonatomic) int flipCount;
@property (strong, nonatomic) Deck *cards;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Deck *)cards
{
    if (!_cards) {
        _cards = [[PlayingCardDeck alloc] init];
    }
    return _cards;
}

- (void)setFlipCount:(int)flipCount
{
    _flipCount = flipCount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipCount];
}

- (IBAction)touchCardButton:(UIButton *)sender {
    // Currently viewing front of card
    if ([sender.currentTitle length]) {
        [sender setBackgroundImage:[UIImage imageNamed:@"cardback"] forState:UIControlStateNormal];
        [sender setTitle:@"" forState:UIControlStateNormal];
    } else {
        Card *nextCard = [self.cards drawRandomCard];
        if (nextCard) {
            [sender setBackgroundImage:[UIImage imageNamed:@"cardfront"] forState:UIControlStateNormal];
            [sender setTitle:nextCard.contents forState:UIControlStateNormal];
        } else {
            return;
        }
    }
    self.flipCount++;
}

@end
