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

// Make an NSError from a given NSException.
- (NSError *)errorFromNSException:(NSException *)exception;

// "safe invoke" various blocks, with try/catch wrapping.
- (void)invokeVoidBlock:(void(^)())block;
- (BOOL)invokeBoolBlock:(BOOL(^)())block;
- (int32_t)invokeInt32Block:(int32_t(^)())block;
- (NSObject *)invokeObjBlock:(NSObject *(^)())block;

// asynchronously invoke the given block, calling back to success/failure on the main thread.
- (void)invokeAsyncInt32Block:(int32_t(^)())block
                        success:(void(^)(int32_t val))success
                        failure:(void(^)(NSError *error))failure;
- (void)invokeAsyncNSArrayBlock:(NSArray *(^)())block
                        success:(void(^)(NSArray *val))success
                        failure:(void(^)(NSError *error))failure;
- (void)invokeAsyncSyncChunkBlock:(EDAMSyncChunk *(^)())block
                          success:(void(^)(EDAMSyncChunk *val))success
                          failure:(void(^)(NSError *error))failure;
- (void)invokeAsyncSyncStateBlock:(EDAMSyncState *(^)())block
                          success:(void(^)(EDAMSyncState *val))success
                          failure:(void(^)(NSError *error))failure;

@end
