/*
 * SKBridgeUserInfo.m
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

#import "SKBridgeUserInfo.h"

static NSString *SKBridgeUserInfoUserIDKey = @"_userID";
static NSString *SKBridgeUserInfoUsernameKey = @"_username";
static NSString *SKBridgeUserInfoUserEmailKey = @"_userEmail";

@implementation SKBridgeUserInfo

@synthesize userID = _userID;
@synthesize username = _username;
@synthesize userEmail = _userEmail;

- (id) initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self != nil) {
    _userID = [aDecoder decodeInt32ForKey:SKBridgeUserInfoUserIDKey];
    _username = [aDecoder decodeObjectForKey:SKBridgeUserInfoUsernameKey];
    _userEmail = [aDecoder decodeObjectForKey:SKBridgeUserInfoUserEmailKey];
  }
  return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeInt32:_userID forKey:SKBridgeUserInfoUserIDKey];
  [aCoder encodeObject:_username forKey:SKBridgeUserInfoUsernameKey];
  [aCoder encodeObject:_userEmail forKey:SKBridgeUserInfoUserEmailKey];
}

@end
