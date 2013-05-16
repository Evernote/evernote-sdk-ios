//
//  SkitchViewController.m
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/14/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "SkitchViewController.h"
#import "SkitchBridge.h"
#import "EvernoteSDK.h"

@implementation SkitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView setImage:[UIImage imageNamed:@"iPhone5_logo.jpg"]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (IBAction)skitchImage:(id)sender {
    if([[SKApplicationBridge sharedSkitchBridge] isSkitchInstalled] == NO) {
        [[EvernoteSession sharedSession] installSkitchAppUsingViewController:self];
    }
    else {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"iPhone5_logo" ofType:@"jpg"];
        [[EvernoteSession sharedSession] setSkitchDelegate:self];
        [[EvernoteNoteStore noteStore] skitchWithData:[NSData dataWithContentsOfFile:filePath] withMimeType:@"image/jpg"];
    }
}

- (void)skitchSaved:(SKBridgeReceipt*)receipt {
    [[self imageView] setImage:[UIImage imageWithData:[receipt resultData]]];
}

- (void)errorFromSkitch:(NSError *)error {
    NSLog(@"Error from skitch : %@",error);
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
