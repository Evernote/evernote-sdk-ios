//
//  ENCredentialStore.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/6/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENCredentials.h"

// Permanent store of Evernote credentials.
// Credentials are unique per (host,consumer key) tuple.
@interface ENCredentialStore : NSObject

// Load the credential store from user defaults.
+ (ENCredentialStore *)load;

// Save the credential store to user defaults.
- (void)save;

// Delete the credential store from user defaults.
// Leaves the keychain intact.
- (void)delete;

// Add credentials to the store.
// Also saves the authentication token to the keychain.
- (void)addCredentials:(ENCredentials *)credentials;

// Look up the credentials for the given host.
- (ENCredentials *)credentialsForHost:(NSString *)host;

// Remove credentials from the store.
// Also deletes the credentials' auth token from the keychain.
- (void)removeCredentials:(ENCredentials *)credentials;

// Remove all credentials from the store.
// Also deletes the credentials' auth tokens from the keychain.
- (void)clearAllCredentials;

@end
