//
//  ENOAuthWindowController.h
//  EvernoteSDK
//
//  Created by Dirk Holtwick on 02.04.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "ENOAuthProtocol.h"

@interface ENOAuthWindowController : NSWindowController

@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (weak) IBOutlet WebView *webView;

@property (nonatomic, weak) id<ENOAuthDelegate> delegate;

- (id)initWithAuthorizationURL:(NSURL *)authorizationURL
           oauthCallbackPrefix:(NSString *)oauthCallbackPrefix
                   profileName:(NSString *)currentProfileName
                allowSwitching:(BOOL)isSwitchingAllowed
                      delegate:(id<ENOAuthDelegate>)delegate;
- (void)updateUIForNewProfile:(NSString*)newProfile withAuthorizationURL:(NSURL*)authURL;

- (void)presentSheetForWindow:(NSWindow *)window;

@end
