/*
 * EvernoteUserStore.h
 * evernote-sdk-ios
 *
 * Copyright 2012 Evernote Corporation
 * All rights reserved. 
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *  
 * 1. Redistributions of source code must retain the above copyright notice, this 
 *    list of conditions and the following disclaimer.
 *     
 * 2. Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 *  
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "EvernoteUserStore.h"

@implementation EvernoteUserStore

+ (instancetype)userStore
{
    EvernoteUserStore *userStore = [[EvernoteUserStore alloc] initWithSession:[EvernoteSession sharedSession]];
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
                  edamVersionMinor:(int16_t)edamVersionMinor
                           success:(void(^)(BOOL versionOK))success
                           failure:(void(^)(NSError *error))failure

{
    [self invokeAsyncBoolBlock:^BOOL{
        return [self.userStore checkVersion:clientName edamVersionMajor:edamVersionMajor edamVersionMinor:edamVersionMinor];
    } success:success failure:failure];
}

- (void)getBootstrapInfoWithLocale:(NSString *)locale
                           success:(void(^)(EDAMBootstrapInfo *info))success
                           failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id {
        return [self.userStore getBootstrapInfo:locale];
    } success:success failure:failure];
}

- (void)getUserWithSuccess:(void(^)(EDAMUser *user))success
                   failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id {
        return [self.userStore getUser:[[EvernoteSession sharedSession] authenticationToken]];
    } success:success failure:failure];
}

- (void)getPublicUserInfoWithUsername:(NSString *)username
                              success:(void(^)(EDAMPublicUserInfo *info))success
                              failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id {
        return [self.userStore getPublicUserInfo:username];
    } success:success failure:failure];
}

- (void)getPremiumInfoWithSuccess:(void(^)(EDAMPremiumInfo *info))success
                          failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id {
        return [self.userStore getPremiumInfo:[[EvernoteSession sharedSession] authenticationToken]];
    } success:success failure:failure];
}

- (void)getNoteStoreUrlWithSuccess:(void(^)(NSString *noteStoreUrl))success
                           failure:(void(^)(NSError *error))failure
{ 
    [self invokeAsyncIdBlock:^id {
        return [self.userStore getNoteStoreUrl:[[EvernoteSession sharedSession] authenticationToken]];
    } success:success failure:failure];
}

- (void)authenticateToBusinessWithSuccess:(void(^)(EDAMAuthenticationResult *authenticationResult))success
                                  failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncIdBlock:^id {
        return [self.userStore authenticateToBusiness:[[EvernoteSession sharedSession] authenticationToken]];
    } success:success failure:failure];
}

- (void)revokeLongSessionWithAuthenticationToken:(NSString*)authenticationToken
                                         success:(void(^)())success
                             failure:(void(^)(NSError *error))failure {
    [self invokeAsyncVoidBlock:^void {
        [self.userStore revokeLongSession:authenticationToken];
    } success:success failure:failure];
}

@end
