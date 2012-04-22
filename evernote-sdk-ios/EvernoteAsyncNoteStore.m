//
//  EvernoteAsyncNoteStore.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/22/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EvernoteAsyncNoteStore.h"

@implementation EvernoteAsyncNoteStore

+ (EvernoteAsyncNoteStore *)noteStore
{
    EvernoteAsyncNoteStore *noteStore = [[[EvernoteAsyncNoteStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    return noteStore;
}

- (id)initWithSession:(EvernoteSession *)session
{
    self = [super initWithSession:session];
    if (self) {
    }
    return self;
}

#pragma mark - NoteStore sync methods

- (void)getSyncStateWithSuccess:(void(^)(EDAMSyncState *syncState))success 
                        failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncBlock:^() {
        success([self.noteStore getSyncState:self.session.authenticationToken]);
    } failure:failure];
}

- (void)getSyncChunkAfterUSN:(int32_t)afterUSN 
                  maxEntries:(int32_t)maxEntries
                fullSyncOnly:(BOOL)fullSyncOnly
                     success:(void(^)(EDAMSyncChunk *syncChunk))success
                     failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncBlock:^() {
        success([self.noteStore getSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:fullSyncOnly]);
    } failure:failure];
}

#pragma mark - NoteStore notebook methods

- (void)listNotebooksWithSuccess:(void(^)(NSArray *notebooks))success
                         failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncBlock:^() {
        success([self.noteStore listNotebooks:self.session.authenticationToken]);
    } failure:failure];    
}

@end
