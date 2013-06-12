//
//  ConsoleViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/15/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "ConsoleViewController.h"

@interface ConsoleViewController ()

@end

@implementation ConsoleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.textView setText:self.consoleText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
