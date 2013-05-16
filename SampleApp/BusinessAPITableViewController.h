//
//  BusinessAPITableViewController.h
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/16/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ENSDKBusinessSampleType) {
    ENSDKListBusinessNotebooks,
    ENCreateBusinessNotebook,
    ENCreateBusinessNote,
    ENBusinessLastRow
};

@interface BusinessAPITableViewController : UITableViewController

@end
