//
//  ENOAuthViewController.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 5/26/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ENOAuthViewController;

@protocol ENOAuthViewControllerDelegate <NSObject>
- (void)oauthViewControllerDidCancel:(ENOAuthViewController *)sender;
- (void)oauthViewController:(ENOAuthViewController *)sender didFailWithError:(NSError *)error;
- (void)oauthViewController:(ENOAuthViewController *)sender receivedOAuthCallbackURL:(NSURL *)url;
@end

@interface ENOAuthViewController : UIViewController

@property (nonatomic, assign) id<ENOAuthViewControllerDelegate> delegate;

- (id)initWithAuthorizationURL:(NSURL *)authorizationURL 
           oauthCallbackPrefix:(NSString *)oauthCallbackPrefix
                      delegate:(id<ENOAuthViewControllerDelegate>)delegate;

@end
