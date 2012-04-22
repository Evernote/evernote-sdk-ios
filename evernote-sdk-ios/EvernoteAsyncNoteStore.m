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
    [self invokeAsyncSyncStateBlock:^EDAMSyncState *() {
        return [self.noteStore getSyncState:self.session.authenticationToken];
    } success:success failure:failure];
}

- (void)getSyncChunkAfterUSN:(int32_t)afterUSN 
                  maxEntries:(int32_t)maxEntries
                fullSyncOnly:(BOOL)fullSyncOnly
                     success:(void(^)(EDAMSyncChunk *syncChunk))success
                     failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncSyncChunkBlock:^EDAMSyncChunk *() {
        return [self.noteStore getSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:fullSyncOnly];
    } success:success failure:failure];
}

- (void)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN
                          maxEntries:(int32_t)maxEntries
                              filter:(EDAMSyncChunkFilter *)filter
                             success:(void(^)(EDAMSyncChunk *syncChunk))success
                             failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncSyncChunkBlock:^EDAMSyncChunk *() {
        return [self.noteStore getFilteredSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:filter];
    } success:success failure:failure];
}

- (void)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook
                           success:(void(^)(EDAMSyncState *syncState))success
                           failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncSyncStateBlock:^EDAMSyncState *() {
        return [self.noteStore getLinkedNotebookSyncState:self.session.authenticationToken:linkedNotebook];
    } success:success failure:failure];
}

#pragma mark - NoteStore notebook methods

- (void)listNotebooksWithSuccess:(void(^)(NSArray *notebooks))success
                         failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncNSArrayBlock:^NSArray *() {
        return [self.noteStore listNotebooks:self.session.authenticationToken];
    } success:success failure:failure];
}

- (void)getNotebookWithGuid:(EDAMGuid)guid 
                    success:(void(^)(EDAMNotebook *syncState))success
                    failure:(void(^)(NSError *error))failure

{
    [self invokeAsyncNotebookBlock:^EDAMNotebook *() {
        return [self.noteStore getNotebook:self.session.authenticationToken:guid];
    } success:success failure:failure];
}

- (void)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook
                          afterUSN:(int32_t)afterUSN
                        maxEntries:(int32_t) maxEntries
                      fullSyncOnly:(BOOL)fullSyncOnly
                           success:(void(^)(EDAMSyncChunk *syncChunk))success
                           failure:(void(^)(NSError *error))failure

{
    [self invokeAsyncSyncChunkBlock:^EDAMSyncChunk *() {
        return [self.noteStore getLinkedNotebookSyncChunk:self.session.authenticationToken:linkedNotebook:afterUSN:maxEntries:fullSyncOnly];
    } success:success failure:failure];
}

- (void)getDefaultNotebookWithSuccess:(void(^)(EDAMNotebook *notebook))success
                              failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncNotebookBlock:^EDAMNotebook *() {
        return [self.noteStore getDefaultNotebook:self.session.authenticationToken];
    } success:success failure:failure];
}

- (void)createNotebook:(EDAMNotebook *)notebook
               success:(void(^)(EDAMNotebook *notebook))success
               failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncNotebookBlock:^EDAMNotebook *() {
        return [self.noteStore createNotebook:self.session.authenticationToken:notebook];
    } success:success failure:failure];
}

- (void)updateNotebook:(EDAMNotebook *)notebook
               success:(void(^)(int32_t usn))success
               failure:(void(^)(NSError *error))failure

{
    [self invokeAsyncInt32Block:^int32_t() {
        return [self.noteStore updateNotebook:self.session.authenticationToken:notebook];
    } success:success failure:failure];
}

- (void)expungeNotebookWithGuid:(EDAMGuid)guid
                        success:(void(^)(int32_t usn))success
                        failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t() {
        return [self.noteStore expungeNotebook:self.session.authenticationToken:guid];
    } success:success failure:failure];
}

@end
