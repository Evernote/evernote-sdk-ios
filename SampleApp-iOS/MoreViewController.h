//
//  MoreViewController.h
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 2/4/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteSDK.h"
#import "NotebookChooserViewController.h"

@interface MoreViewController : UIViewController <ENSessionDelegate,NotebookChooserViewControllerDelegate>

- (IBAction)saveNewNote:(id)sender;
- (IBAction)viewNote:(id)sender;
- (IBAction)installEvernote:(id)sender;
- (IBAction)invlokeNotebookChooser:(id)sender;
- (IBAction)createBusinessNote:(id)sender;

@end
