//
//  ENAPI.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/21/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ENAPI.h"
#import "EDAM.h"

@interface ENAPI()

@end

@implementation ENAPI

@synthesize session = _session;
@synthesize error = _error;
@dynamic noteStore;
@dynamic userStore;

- (void)dealloc
{
    [_session release];
    [super dealloc];
}

- (id)initWithSession:(EvernoteSession *)session
{
    self = [super init];
    if (self) {
        self.session = session;
    }
    return self;
}

- (EDAMNoteStoreClient *)noteStore
{
    return [self.session noteStore];
}

- (EDAMUserStoreClient *)userStore
{
    return [self.session userStore];    
}

- (void)populateErrorFromNSException:(NSException *)exception
{
    if (exception) {
        int errorCode = EDAMErrorCode_UNKNOWN;
        if ([exception respondsToSelector:@selector(errorCode)]) {
            // Evernote Thrift exception classes have an errorCode property
            errorCode = [(id)exception errorCode];
        }
        self.error = [NSError errorWithDomain:kEvernoteSDKErrorDomain code:errorCode userInfo:exception.userInfo];
    }
}

- (void)invokeVoidBlock:(void(^)())block
{
    self.error = nil;
    @try {
        block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }
}

- (BOOL)invokeBoolBlock:(BOOL(^)())block
{
    self.error = nil;
    BOOL retVal = NO;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }  
    return retVal;
}

- (int32_t)invokeInt32Block:(int32_t(^)())block
{
    self.error = nil;
    int32_t retVal = 0;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }  
    return retVal;
}

- (int64_t)invokeInt64Block:(int64_t(^)())block
{
    self.error = nil;
    int32_t retVal = 0;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }  
    return retVal;
}

- (NSObject *)invokeObjBlock:(NSObject *(^)())block
{
    self.error = nil;
    NSObject *retVal = nil;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }  
    return retVal;   
}

@end
