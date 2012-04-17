//
//  ENCredentialStore.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/6/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ENCredentialStore.h"

#define DEFAULTS_CREDENTIAL_STORE_KEY @"EvernoteCredentials"

@interface ENCredentialStore() <NSCoding>

@property (nonatomic, retain) NSMutableDictionary *store;

@end

@implementation ENCredentialStore

@synthesize store = _store;

- (void)dealloc
{
    [_store release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.store = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (ENCredentialStore *)load
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:DEFAULTS_CREDENTIAL_STORE_KEY];
    ENCredentialStore *store = nil;
    if (data) {
        @try {
            store = [NSKeyedUnarchiver unarchiveObjectWithData:data];    
        }
        @catch (NSException *exception) {
            // Deal with things like NSInvalidUnarchiveOperationException
            // just return nil for situations like this, and the caller
            // can create and save a new credentials store.
            NSLog(@"Exception unarchiving ENCredentialStore: %@", exception);
        }
    }
    return store;
}

- (void)save
{
    // we use our own archiver, 
    // since the credentialStore dict contains non-property list objects
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:DEFAULTS_CREDENTIAL_STORE_KEY];
    [defaults synchronize];
}

- (void)delete
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:DEFAULTS_CREDENTIAL_STORE_KEY];
    [defaults synchronize];        
}

- (void)addCredentials:(ENCredentials *)credentials
{
    // saves auth token to keychain
    [credentials saveToKeychain];
    
    // add it to our host => credentials dict
    [self.store setObject:credentials forKey:credentials.host];
    [self save];
}

- (ENCredentials *)credentialsForHost:(NSString *)host
{
    return [self.store objectForKey:host];
}

- (void)removeCredentials:(ENCredentials *)credentials
{
    // delete auth token from keychain
    [credentials deleteFromKeychain];
    
    // update user defaults
    [self.store removeObjectForKey:credentials.host];
    
    [self save];
}

- (void)clearAllCredentials
{
    for (ENCredentials *credentials in [self.store allValues]) {
        [credentials deleteFromKeychain];
    }
    [self.store removeAllObjects];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.store forKey:@"store"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.store = [decoder decodeObjectForKey:@"store"];
    }
    return self;
}

@end
