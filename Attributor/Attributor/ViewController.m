//
//  ViewController.m
//  Attributor
//
//  Created by Rachel Lew on 2/6/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "ViewController.h"
#import "TextStatsViewController.h"

@interface ViewController ()

- (void)preferredFontsChanged:(NSNotification *) notification;
- (void)usePreferredFonts;
- (IBAction)touchColoredButtonToChangeSelectedBodyTextColor:(UIButton *)sender;
- (IBAction)addOutlineToSelectedText:(id)sender;
- (IBAction)removeOutlineOnSelectedText:(id)sender;

@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    NSMutableAttributedString *title =
        [[NSMutableAttributedString alloc] initWithString:self.outlineButton.currentTitle
                                               attributes:@{ NSStrokeWidthAttributeName : @4, NSStrokeColorAttributeName : self.outlineButton.tintColor }];
    [self.outlineButton setAttributedTitle:title forState:UIControlStateNormal];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self usePreferredFonts];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AnalyzeText"]) {
        if ([segue.destinationViewController isKindOfClass:[TextStatsViewController class]]) {
            TextStatsViewController *destVC = segue.destinationViewController;
            destVC.textToAnalyze = self.body.textStorage;
        }
    }
}

- (void)preferredFontsChanged:(NSNotification *) notification
{
    [self usePreferredFonts];
}

- (void)usePreferredFonts
{
    self.body.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.headline.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (IBAction)touchColoredButtonToChangeSelectedBodyTextColor:(UIButton *)sender {
    [self.body.textStorage addAttribute:NSForegroundColorAttributeName
                                  value: sender.backgroundColor
                                  range: [self.body selectedRange]];
}
- (IBAction)addOutlineToSelectedText:(id)sender {
    [self.body.textStorage addAttributes:@{ NSStrokeWidthAttributeName : @-4, NSStrokeColorAttributeName : [UIColor blackColor] }
                                   range: self.body.selectedRange ];
}

- (IBAction)removeOutlineOnSelectedText:(id)sender {
    [self.body.textStorage removeAttribute:NSStrokeWidthAttributeName
                                     range:self.body.selectedRange];
    [self.body.textStorage removeAttribute:NSStrokeColorAttributeName
                                     range:self.body.selectedRange];
}

@end
