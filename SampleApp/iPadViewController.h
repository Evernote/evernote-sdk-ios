//
//  iPadViewController.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 6/12/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPadViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>

- (IBAction)authenticate:(id)sender;
- (IBAction)listNotebooks:(id)sender;
- (IBAction)listSharedNotes:(id)sender;
- (IBAction)listBusinessNotebooks:(id)sender;
- (IBAction)createPhotoNote:(id)sender;
- (IBAction)logout:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *authenticateButton;
@property (strong, nonatomic) IBOutlet UIButton *listNotebooksButton;
@property (strong, nonatomic) IBOutlet UIButton *listBusinessButton;
@property (strong, nonatomic) IBOutlet UIButton *photoNoteButton;
@property (strong, nonatomic) IBOutlet UIButton *sharedNotesButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@end
