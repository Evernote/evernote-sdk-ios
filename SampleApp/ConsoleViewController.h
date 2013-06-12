//
//  ConsoleViewController.h
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/15/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConsoleViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic,copy) NSString* consoleText;

@end
