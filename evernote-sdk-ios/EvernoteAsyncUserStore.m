//
//  EvernoteAsyncUserStore.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/22/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EvernoteAsyncUserStore.h"

@implementation EvernoteAsyncUserStore


+ (EvernoteAsyncUserStore *)userStore
{
    EvernoteAsyncUserStore *userStore = [[[EvernoteAsyncUserStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    return userStore;
}

- (id)initWithSession:(EvernoteSession *)session
{
    self = [super initWithSession:session];
    if (self) {
    }
    return self;
}

#pragma mark - UserStore methods

- (void)checkVersionWithClientName:(NSString *)clientName 
                  edamVersionMajor:(int16_t)edamVersionMajor 
                  edamVersionMinor:(int16_t) edamVersionMinor
                           success:(void(^)(BOOL versionOK))success
                           failure:(void(^)(NSError *error))failure

{
    [self invokeAsyncBoolBlock:^BOOL() {
        return [self.userStore checkVersion:clientName:edamVersionMajor:edamVersionMinor];
    } success:success failure:failure];
}

- (void)getBootstrapInfoWithLocale:(NSString *)locale
                           success:(void(^)(EDAMBootstrapInfo *info))success
                           failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id() {
        return [self.userStore getBootstrapInfo:locale];
    } success:success failure:failure];
}

- (void)getUserWithSuccess:(void(^)(EDAMUser *user))success
                   failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id() {
        return [self.userStore getUser:self.session.authenticationToken];
    } success:success failure:failure];
}

- (void)getPublicUserInfoWithUsername:(NSString *)username
                              success:(void(^)(EDAMPublicUserInfo *info))success
                              failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id() {
        return [self.userStore getPublicUserInfo:self.session.authenticationToken];
    } success:success failure:failure];
}

- (void)getPremiumInfoWithSuccess:(void(^)(EDAMPremiumInfo *info))success
                          failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id() {
        return [self.userStore getPremiumInfo:self.session.authenticationToken];
    } success:success failure:failure];
}

- (void)getNoteStoreUrlWithSuccess:(void(^)(NSString *noteStoreUrl))success
                           failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id() {
        return [self.userStore getNoteStoreUrl:self.session.authenticationToken];
    } success:success failure:failure];
}

@end
