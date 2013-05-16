//
//  SkitchViewController.h
//  evernote-sdk-ios
//
//  Created by Mustafa Furniturewala on 5/14/13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvernoteSDK.h"

@interface SkitchViewController : UIViewController<ENSessionSkitchDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)skitchImage:(id)sender;

@end
