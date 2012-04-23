/*
 * EvernoteUserStore.m
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

#pragma mark - UserStore methods

- (BOOL)checkVersionWithClientName:(NSString *)clientName 
                  edamVersionMajor:(int16_t)edamVersionMajor 
                  edamVersionMinor:(int16_t)edamVersionMinor
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
