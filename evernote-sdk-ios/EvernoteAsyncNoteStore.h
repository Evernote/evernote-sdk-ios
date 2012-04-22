//
//  EvernoteAsyncNoteStore.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/22/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENAPI.h"

@interface EvernoteAsyncNoteStore : ENAPI

// Get an instance, using the shared EvernoteSession.
+ (EvernoteAsyncNoteStore *)noteStore;

// Construct an instance with the given session.
- (id)initWithSession:(EvernoteSession *)session;

// NoteStore sync methods
- (void)getSyncStateWithSuccess:(void(^)(EDAMSyncState *syncState))success 
                        failure:(void(^)(NSError *error))failure;
- (void)getSyncChunkAfterUSN:(int32_t)afterUSN 
                  maxEntries:(int32_t)maxEntries
                fullSyncOnly:(BOOL)fullSyncOnly
                     success:(void(^)(EDAMSyncChunk *syncChunk))success
                     failure:(void(^)(NSError *error))failure;

// NoteStore notebook methods
- (void)listNotebooksWithSuccess:(void(^)(NSArray *notebooks))success
                         failure:(void(^)(NSError *error))failure;

@end
