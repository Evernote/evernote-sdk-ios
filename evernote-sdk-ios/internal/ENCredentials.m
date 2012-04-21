//
//  ENCredentials.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/5/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ENCredentials.h"
#import "SSKeychain.h"

@interface ENCredentials()

@end

@implementation ENCredentials

@synthesize host = _host;
@synthesize edamUserId = _edamUserId;
@synthesize noteStoreUrl = _noteStoreUrl;
@synthesize authenticationToken = _authenticationToken;

- (void)dealloc
{
    [_edamUserId release];
    [_noteStoreUrl release];
    [super dealloc];
}

- (id)initWithHost:(NSString *)host
        edamUserId:(NSString *)edamUserId
      noteStoreUrl:(NSString *)noteStoreUrl
authenticationToken:(NSString *)authenticationToken
{
    self = [super init];
    if (self) {
        self.host = host;
        self.edamUserId = edamUserId;
        self.noteStoreUrl = noteStoreUrl;
        self.authenticationToken = authenticationToken;
    }
    return self;
}

- (BOOL)saveToKeychain
{
    // auth token gets saved to the keychain
    NSError *error;
    BOOL success = [SSKeychain setPassword:_authenticationToken 
                                forService:self.host
                                   account:self.edamUserId 
                                     error:&error];
    if (!success) {
        NSLog(@"Error saving to keychain: %@ %d", error, error.code);
        return NO;
    } 
    return YES;
}

- (void)deleteFromKeychain
{
    [SSKeychain deletePasswordForService:self.host account:self.edamUserId];
}

- (NSString *)authenticationToken
{
    NSError *error;
    NSString *token = [SSKeychain passwordForService:self.host account:self.edamUserId error:&error];
    if (!token) {
        NSLog(@"Error getting password from keychain: %@", error);
    }
    return token;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.host forKey:@"host"];
    [encoder encodeObject:self.edamUserId forKey:@"edamUserId"];
    [encoder encodeObject:self.noteStoreUrl forKey:@"noteStoreUrl"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.host = [decoder decodeObjectForKey:@"host"];
        self.edamUserId = [decoder decodeObjectForKey:@"edamUserId"];
        self.noteStoreUrl = [decoder decodeObjectForKey:@"noteStoreUrl"];
    }
    return self;
}

@end
