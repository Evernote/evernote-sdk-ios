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
- (IBAction)logout:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *authenticateButton;
@property (retain, nonatomic) IBOutlet UIButton *listNotebooksButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;

@end
