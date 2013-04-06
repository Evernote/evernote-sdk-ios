//
//  AppDelegate.m
//  SampleApp-Mac
//
//  Created by Dirk Holtwick on 02.04.13.
//  Copyright (c) 2013 n/a. All rights reserved.
//

#import "AppDelegate.h"
#import <EvernoteSDK-Mac/EvernoteSDK.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Override point for customization after application launch.

    // Initial development is done on the sandbox service
    // Change this to BootstrapServerBaseURLStringUS to use the production Evernote service
    // Change this to BootstrapServerBaseURLStringCN to use the Yinxiang Biji production service
    // BootstrapServerBaseURLStringSandbox does not support the  Yinxiang Biji service
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;

#warning Add Consumer Key and Consumer Secret, but also modify Info.plist according to documentation!
#warning Remove these warnings once done with it.

    // Fill in the consumer key and secret with the values that you received from Evernote
    // To get an API key, visit http://dev.evernote.com/documentation/cloud/
    NSString *CONSUMER_KEY = @"your key";
    NSString *CONSUMER_SECRET = @"your secret";

    // set up Evernote session singleton
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
}

- (IBAction)doAuthenticate:(id)sender {
    EvernoteSession *session = [EvernoteSession sharedSession];
    NSLog(@"Session %@", session);
    [session authenticateWithWindow:self.window completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            NSRunCriticalAlertPanel(@"Error", @"Could not authenticate", @"OK", nil, nil);
        }
        else {
            NSLog(@"authenticated! noteStoreUrl:%@ webApiUrlPrefix:%@", session.noteStoreUrl, session.webApiUrlPrefix);

            EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
            [noteStore listNotebooksWithSuccess:^(NSArray *notebooks) {
                self.content = notebooks;
                NSLog(@"notebooks: %@", notebooks);
            } failure:^(NSError *error2) {
                NSLog(@"error %@", error2);
            }];
        }
    }];
}

@end
