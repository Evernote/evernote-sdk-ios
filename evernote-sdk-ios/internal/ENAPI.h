//
//  ENAPI.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/21/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDAM.h"
#import "EvernoteSession.h"

// Superclass for Evernote API classes (EvernoteNoteStore, EvernoteUserStore, etc.)
@interface ENAPI : NSObject

// Error from latest API call, if any.
@property (nonatomic, retain) NSError *error;
@property (nonatomic, retain) EvernoteSession *session;
@property (nonatomic, readonly) EDAMNoteStoreClient *noteStore;
@property (nonatomic, readonly) EDAMUserStoreClient *userStore;

- (id)initWithSession:(EvernoteSession *)session;

// set our error property from a given NSException.
- (void)populateErrorFromNSException:(NSException *)exception;

// "safe invoke" various blocks, with try/catch wrapping.
- (void)invokeVoidBlock:(void(^)())block;
- (BOOL)invokeBoolBlock:(BOOL(^)())block;
- (int32_t)invokeInt32Block:(int32_t(^)())block;
- (int64_t)invokeInt64Block:(int64_t(^)())block;
- (NSObject *)invokeObjBlock:(NSObject *(^)())block;

@end
