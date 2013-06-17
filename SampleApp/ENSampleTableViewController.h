//
//  ENSampleTableViewController.h
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/15/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteSDK.h"
#import "NotebookChooserViewController.h"

typedef NS_ENUM(NSInteger, ENSDKSampleType) {
    ENSDKListNotebooks,
    ENListSharedNotes,
    ENCreatePhotoNote,
    ENCreateReminderNote,
    ENShowBusinessAPI,
    ENSaveNewNoteToEvernote,
    ENInstallEvernoteForiOS,
    ENViewNoteInEvernote,
    ENNoteBrowser,
    ENNotebookChooser,
    ENLastRow
};

@interface ENSampleTableViewController : UITableViewController <ENSessionDelegate,NotebookChooserViewControllerDelegate>

@property (nonatomic,assign) BOOL isBusiness;

@end
