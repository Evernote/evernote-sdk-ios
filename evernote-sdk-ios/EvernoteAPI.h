//
//  EvernoteAPI.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/20/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteSession.h"

@interface EvernoteAPI : NSObject

// get an API object, using the shared EvernoteSession
+ (EvernoteAPI *)api;

// construct an API object with the given session
- (id)initWithSession:(EvernoteSession *)session;

// NoteStore sync methods
- (EDAMSyncState *)getSyncStateWithError:(NSError **)error;
- (EDAMSyncChunk *)getSyncChunkAfterUSN:(int32_t)afterUSN 
                             maxEntries:(int32_t)maxEntries
                           fullSyncOnly:(BOOL)fullSyncOnly
                                  error:(NSError **)error;
- (EDAMSyncChunk *)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN
                                     maxEntries:(int32_t)maxEntries
                                         filter:(EDAMSyncChunkFilter *)filter
                                          error:(NSError **)error;
- (EDAMSyncState *)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook
                                        error:(NSError **)error;

// NoteStore notebook methods
- (NSArray *)listNotebooksWithError:(NSError **)error;
- (EDAMNotebook *)getNotebookWithGuid:(EDAMGuid)guid 
                                error:(NSError **)error;
- (EDAMSyncChunk *)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook
                                     afterUSN:(int32_t)afterUSN
                                   maxEntries:(int32_t) maxEntries
                                 fullSyncOnly:(BOOL)fullSyncOnly
                                        error:(NSError **)error;
- (EDAMNotebook *)getDefaultNotebookWithError:(NSError **)error;
- (EDAMNotebook *)createNotebook:(EDAMNotebook *)notebook
                           error:(NSError **)error;
- (int32_t)updateNotebook:(EDAMNotebook *)notebook
                    error:(NSError **)error;

// NoteStore tag methods

@end
