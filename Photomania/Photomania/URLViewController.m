//
//  URLViewController.m
//  Photomania
//
//  Created by Rachel Lew on 3/10/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController ()

@property (weak, nonatomic) IBOutlet UITextView *urlText;

@end

@implementation URLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
}

- (void)updateUI
{
    self.urlText.text = self.url.absoluteString;
}

- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self updateUI];
}

@end
