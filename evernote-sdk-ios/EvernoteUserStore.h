//
//  EvernoteUserStore.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/21/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENAPI.h"

@interface EvernoteUserStore : ENAPI

// Get an instance, using the shared EvernoteSession.
+ (EvernoteUserStore *)userStore;

// Construct an instance with the given session.
- (id)initWithSession:(EvernoteSession *)session;

// UserStore methods

#warning do we want to NOT expose some of these, wrt auth?
- (BOOL)checkVersionWithClientName:(NSString *)clientName 
                  edamVersionMajor:(int16_t)edamVersionMajor 
                  edamVersionMinor:(int16_t) edamVersionMinor;
- (EDAMBootstrapInfo *)getBootstrapInfoWithLocale:(NSString *)locale;
- (EDAMAuthenticationResult *)authenticateWithUsername:(NSString *)username 
                                              password:(NSString *)password 
                                           consumerKey:(NSString *)consumerKey 
                                        consumerSecret:(NSString *)consumerSecret;
- (EDAMAuthenticationResult *)refreshAuthentication:(NSString *)authenticationToken;
- (EDAMUser *)getUser;
- (EDAMPublicUserInfo *)getPublicUserInfoWithUsername:(NSString *)username;
- (EDAMPremiumInfo *)getPremiumInfo;
- (NSString *)getNoteStoreUrl;

@end
