//
//  EvernoteUserStore.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/21/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EvernoteUserStore.h"

@implementation EvernoteUserStore

+ (EvernoteUserStore *)userStore
{
    EvernoteUserStore *userStore = [[[EvernoteUserStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    return userStore;
}

- (id)initWithSession:(EvernoteSession *)session
{
    self = [super initWithSession:session];
    if (self) {
    }
    return self;
}

#pragma mark UserStore methods

- (BOOL)checkVersionWithClientName:(NSString *)clientName 
                  edamVersionMajor:(int16_t)edamVersionMajor 
                  edamVersionMinor:(int16_t) edamVersionMinor
{
    return [self invokeBoolBlock:^BOOL() {
        return [self.userStore checkVersion:clientName:edamVersionMajor:edamVersionMinor];
    }]; 
}

- (EDAMBootstrapInfo *)getBootstrapInfoWithLocale:(NSString *)locale
{
    return (EDAMBootstrapInfo *)[self invokeObjBlock:^NSObject *() {
        return [self.userStore getBootstrapInfo:locale];
    }];
}

- (EDAMAuthenticationResult *)authenticateWithUsername:(NSString *)username 
                                              password:(NSString *)password 
                                           consumerKey:(NSString *)consumerKey 
                                        consumerSecret:(NSString *)consumerSecret
{
    return (EDAMAuthenticationResult *)[self invokeObjBlock:^NSObject *() {
        return [self.userStore authenticate:username :password:consumerKey:consumerSecret];
    }];
}

- (EDAMAuthenticationResult *)refreshAuthentication:(NSString *)authenticationToken
{
    return (EDAMAuthenticationResult *)[self invokeObjBlock:^NSObject *() {
        return [self.userStore refreshAuthentication:self.session.authenticationToken];
    }];
}

- (EDAMUser *)getUser
{
    return (EDAMUser *)[self invokeObjBlock:^NSObject *() {
        return [self.userStore getUser:self.session.authenticationToken];
    }];
}

- (EDAMPublicUserInfo *)getPublicUserInfoWithUsername:(NSString *)username
{
    return (EDAMPublicUserInfo *)[self invokeObjBlock:^NSObject *() {
        return [self.userStore getPublicUserInfo:self.session.authenticationToken];
    }]; 
}

- (EDAMPremiumInfo *)getPremiumInfo
{
    return (EDAMPremiumInfo *)[self invokeObjBlock:^NSObject *() {
        return [self.userStore getPremiumInfo:self.session.authenticationToken];
    }];
}

- (NSString *)getNoteStoreUrl
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.userStore getNoteStoreUrl:self.session.authenticationToken];
    }];
}

@end
