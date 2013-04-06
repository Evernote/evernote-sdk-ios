//
//  NotbookChooserViewController.h
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 2/11/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EDAMNotebook;
@class NotebookChooserViewController;

@protocol NotebookChooserViewControllerDelegate <NSObject>
-(void)notebookChooserController:(NotebookChooserViewController*)controller didSelectNotebook:(EDAMNotebook*)notebook;
@end

@interface NotebookChooserViewController : UITableViewController

@property(nonatomic, assign) id <NotebookChooserViewControllerDelegate> delegate;
@property(nonatomic, strong) EDAMNotebook *selectedNotebook;
@property(nonatomic, strong) NSIndexPath *selectedIndex;

- (void)setSelectedNotebookWithGUID:(NSString *)notebookGUID;
- (void)setSelectedNotebookWithName:(NSString *)notebookName;

@end
