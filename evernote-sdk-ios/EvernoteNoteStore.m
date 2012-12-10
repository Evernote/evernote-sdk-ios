/*
 * EvernoteNoteStore.m
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

#import "EvernoteNoteStore.h"

@interface EvernoteNoteStore ()

@property (nonatomic,assign) BOOL isBusiness;
@property (nonatomic,retain) EDAMLinkedNotebook* linkedNotebook;

@end

@implementation EvernoteNoteStore

+ (EvernoteNoteStore *)noteStore
{
    EvernoteNoteStore *noteStore = [[[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    noteStore.isBusiness = NO;
    noteStore.linkedNotebook = nil;
    return noteStore;
}

+ (EvernoteNoteStore *)businessNoteStore
{
    EvernoteNoteStore *noteStore = [[[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    noteStore.isBusiness = YES;
    noteStore.linkedNotebook = nil;
    return noteStore;
}

+ (EvernoteNoteStore *)noteStoreForLinkedNotebook:(EDAMLinkedNotebook*)notebook
{
    EvernoteNoteStore *noteStore = [[[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    noteStore.isBusiness = NO;
    noteStore.linkedNotebook = notebook;
    return noteStore;
}

-  (EDAMNoteStoreClient*)currentNoteStore
{
    if(self.linkedNotebook) {
        EDAMNoteStoreClient* noteStoreClient = [[EvernoteSession sharedSession] noteStoreWithNoteStoreURL:self.linkedNotebook.noteStoreUrl];
        return noteStoreClient;
    }
    else if(self.isBusiness) {
        return self.businessNoteStore;
    }
    return self.noteStore;
}

- (NSString*)authenticationToken {
    EvernoteSession* sharedSession = [EvernoteSession sharedSession];
    if(self.linkedNotebook) {
        EDAMNoteStoreClient* noteStoreClient = [sharedSession noteStoreWithNoteStoreURL:self.linkedNotebook.noteStoreUrl];
        EDAMAuthenticationResult* authResult = [noteStoreClient authenticateToSharedNotebook:self.linkedNotebook.shareKey :sharedSession.authenticationToken];
        return authResult.authenticationToken;
    }
    else if(self.isBusiness) {
        return self.session.businessAuthenticationToken;
    }
    return self.session.authenticationToken;
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
    [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getSyncState:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)getSyncChunkAfterUSN:(int32_t)afterUSN 
                  maxEntries:(int32_t)maxEntries
                fullSyncOnly:(BOOL)fullSyncOnly
                     success:(void(^)(EDAMSyncChunk *syncChunk))success
                     failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
         return [[self currentNoteStore] getSyncChunk:[self authenticationToken]:afterUSN:maxEntries:fullSyncOnly];
    } success:success failure:failure];
}

- (void)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN
                          maxEntries:(int32_t)maxEntries
                              filter:(EDAMSyncChunkFilter *)filter
                             success:(void(^)(EDAMSyncChunk *syncChunk))success
                             failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
         return [[self currentNoteStore] getFilteredSyncChunk:[self authenticationToken]:afterUSN:maxEntries:filter];
    } success:success failure:failure];
}

- (void)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook
                           success:(void(^)(EDAMSyncState *syncState))success
                           failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
         return [[self currentNoteStore] getLinkedNotebookSyncState:[self authenticationToken]:linkedNotebook];
    } success:success failure:failure];
}

#pragma mark - NoteStore notebook methods

- (void)listNotebooksWithSuccess:(void(^)(NSArray *notebooks))success
                         failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
         return [[self currentNoteStore] listNotebooks:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)getNotebookWithGuid:(EDAMGuid)guid 
                    success:(void(^)(EDAMNotebook *notebook))success
                    failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
         return [[self currentNoteStore] getNotebook:[self authenticationToken]:guid];
     } success:success failure:failure];
}

- (void)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook
                          afterUSN:(int32_t)afterUSN
                        maxEntries:(int32_t) maxEntries
                      fullSyncOnly:(BOOL)fullSyncOnly
                           success:(void(^)(EDAMSyncChunk *syncChunk))success
                           failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
         return [[self currentNoteStore] getLinkedNotebookSyncChunk:[self authenticationToken]:linkedNotebook:afterUSN:maxEntries:fullSyncOnly];
    } success:success failure:failure];
}

- (void)getDefaultNotebookWithSuccess:(void(^)(EDAMNotebook *notebook))success
                              failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
         return [[self currentNoteStore] getDefaultNotebook:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)createNotebook:(EDAMNotebook *)notebook
               success:(void(^)(EDAMNotebook *notebook))success
               failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createNotebook:[self authenticationToken]:notebook];
    } success:success failure:failure];
}

- (void)updateNotebook:(EDAMNotebook *)notebook
               success:(void(^)(int32_t usn))success
               failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateNotebook:[self authenticationToken]:notebook];
    } success:success failure:failure];
}

- (void)expungeNotebookWithGuid:(EDAMGuid)guid
                        success:(void(^)(int32_t usn))success
                        failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeNotebook:[self authenticationToken]:guid];
    } success:success failure:failure];
}

#pragma mark - NoteStore tags methods

- (void)listTagsWithSuccess:(void(^)(NSArray *tags))success
                    failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listTags:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)listTagsByNotebookWithGuid:(EDAMGuid)guid
                           success:(void(^)(NSArray *tags))success
                           failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listTagsByNotebook:[self authenticationToken]:guid];
    } success:success failure:failure];
};

- (void)getTagWithGuid:(EDAMGuid)guid
               success:(void(^)(EDAMTag *tag))success
               failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getTag:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)createTag:(EDAMTag *)tag
          success:(void(^)(EDAMTag *tag))success
          failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createTag:[self authenticationToken]:tag];
    } success:success failure:failure];
}

- (void)updateTag:(EDAMTag *)tag
          success:(void(^)(int32_t usn))success
          failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateTag:[self authenticationToken]:tag];
    } success:success failure:failure];
}

- (void)untagAllWithGuid:(EDAMGuid)guid
                 success:(void(^)())success
                 failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncVoidBlock:^ {
        [[self currentNoteStore] untagAll:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)expungeTagWithGuid:(EDAMGuid)guid
                   success:(void(^)(int32_t usn))success
                   failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeTag:[self authenticationToken]:guid];
    } success:success failure:failure];
}

#pragma mark - NoteStore search methods

- (void)listSearchesWithSuccess:(void(^)(NSArray *searches))success
                        failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listSearches:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)getSearchWithGuid:(EDAMGuid)guid
                  success:(void(^)(EDAMSavedSearch *search))success
                  failure:(void(^)(NSError *error))failure

{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getSearch:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)createSearch:(EDAMSavedSearch *)search
             success:(void(^)(EDAMSavedSearch *search))success
             failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createSearch:[self authenticationToken]:search];
    } success:success failure:failure];
}

- (void)updateSearch:(EDAMSavedSearch *)search
             success:(void(^)(int32_t usn))success
             failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateSearch:[self authenticationToken]:search];
    } success:success failure:failure];
}

- (void)expungeSearchWithGuid:(EDAMGuid)guid
                      success:(void(^)(int32_t usn))success
                      failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeSearch:[self authenticationToken]:guid];
    } success:success failure:failure];
}

#pragma mark - NoteStore notes methods
- (void)findRealtedWithQuery:(EDAMRelatedQuery *)query
                  resultSpec:(EDAMRelatedResultSpec *)resultSpec
                     success:(void(^)(EDAMRelatedResult *result))success
                     failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findRelated:[self authenticationToken]:query:resultSpec];
    } success:success failure:failure];
}

- (void)findNotesWithFilter:(EDAMNoteFilter *)filter 
                     offset:(int32_t)offset
                   maxNotes:(int32_t)maxNotes
                    success:(void(^)(EDAMNoteList *list))success
                    failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findNotes:[self authenticationToken]:filter:offset:maxNotes];
    } success:success failure:failure];
}

- (void)findNoteOffsetWithFilter:(EDAMNoteFilter *)filter 
                            guid:(EDAMGuid)guid
                         success:(void(^)(int32_t offset))success
                         failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] findNoteOffset:[self authenticationToken]:filter:guid];
    } success:success failure:failure];
}

- (void)findNotesMetadataWithFilter:(EDAMNoteFilter *)filter
                             offset:(int32_t)offset 
                           maxNotes:(int32_t)maxNotes 
                         resultSpec:(EDAMNotesMetadataResultSpec *)resultSpec
                            success:(void(^)(EDAMNotesMetadataList *metadata))success
                            failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findNotesMetadata:[self authenticationToken]:filter:offset:maxNotes:resultSpec];
    } success:success failure:failure];
}

- (void)findNoteCountsWithFilter:(EDAMNoteFilter *)filter 
                       withTrash:(BOOL)withTrash
                         success:(void(^)(EDAMNoteCollectionCounts *counts))success
                         failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] findNoteCounts:[self authenticationToken]:filter:withTrash];
    } success:success failure:failure];
}

- (void)getNoteWithGuid:(EDAMGuid)guid 
            withContent:(BOOL)withContent 
      withResourcesData:(BOOL)withResourcesData 
withResourcesRecognition:(BOOL)withResourcesRecognition 
withResourcesAlternateData:(BOOL)withResourcesAlternateData
                success:(void(^)(EDAMNote *note))success
                failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNote:[self authenticationToken]:guid:withContent:withResourcesData:withResourcesRecognition:withResourcesAlternateData];
    } success:success failure:failure];
}

- (void)getNoteApplicationDataWithGuid:(EDAMGuid)guid
                               success:(void(^)(EDAMLazyMap *map))success
                               failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteApplicationData:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                        key:(NSString *)key
                                    success:(void(^)(NSString *entry))success
                                    failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteApplicationDataEntry:[self authenticationToken]:guid:key];
    } success:success failure:failure];
}

- (void)setNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                        key:(NSString *)key 
                                      value:(NSString *)value
                                    success:(void(^)(int32_t usn))success
                                    failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] setNoteApplicationDataEntry:[self authenticationToken]:guid:key:value];
    } success:success failure:failure];
}

- (void)unsetNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                          key:(NSString *) key
                                      success:(void(^)(int32_t usn))success
                                      failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] unsetNoteApplicationDataEntry:[self authenticationToken]:guid:key];
    } success:success failure:failure];
}

- (void)getNoteContentWithGuid:(EDAMGuid)guid
                       success:(void(^)(NSString *content))success
                       failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteContent:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getNoteSearchTextWithGuid:(EDAMGuid)guid 
                         noteOnly:(BOOL)noteOnly
              tokenizeForIndexing:(BOOL)tokenizeForIndexing
                          success:(void(^)(NSString *text))success
                          failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteSearchText:[self authenticationToken]:guid:noteOnly:tokenizeForIndexing];
    } success:success failure:failure];
}

- (void)getResourceSearchTextWithGuid:(EDAMGuid)guid
                              success:(void(^)(NSString *text))success
                              failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceSearchText:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getNoteTagNamesWithGuid:(EDAMGuid)guid
                        success:(void(^)(NSArray *names))success
                        failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteTagNames:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)createNote:(EDAMNote *)note
           success:(void(^)(EDAMNote *note))success
           failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createNote:[self authenticationToken]:note];
    } success:success failure:failure];
}

- (void)updateNote:(EDAMNote *)note
           success:(void(^)(EDAMNote *note))success
           failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] updateNote:[self authenticationToken]:note];
    } success:success failure:failure];
}

- (void)deleteNoteWithGuid:(EDAMGuid)guid
                   success:(void(^)(int32_t usn))success
                   failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] deleteNote:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)expungeNoteWithGuid:(EDAMGuid)guid
                    success:(void(^)(int32_t usn))success
                    failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeNote:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)expungeNotesWithGuids:(NSArray *)guids
                      success:(void(^)(int32_t usn))success
                      failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeNotes:[self authenticationToken]:guids];
    } success:success failure:failure];
}

- (void)expungeInactiveNoteWithSuccess:(void(^)(int32_t usn))success
                               failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeInactiveNotes:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)copyNoteWithGuid:(EDAMGuid)guid 
          toNoteBookGuid:(EDAMGuid)toNotebookGuid
                 success:(void(^)(EDAMNote *note))success
                 failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] copyNote:[self authenticationToken]:guid:toNotebookGuid];
    } success:success failure:failure];
}

- (void)listNoteVersionsWithGuid:(EDAMGuid)guid
                         success:(void(^)(NSArray *versions))success
                         failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listNoteVersions:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getNoteVersionWithGuid:(EDAMGuid)guid 
             updateSequenceNum:(int32_t)updateSequenceNum 
             withResourcesData:(BOOL)withResourcesData 
      withResourcesRecognition:(BOOL)withResourcesRecognition 
    withResourcesAlternateData:(BOOL)withResourcesAlternateData
                       success:(void(^)(EDAMNote *note))success
                       failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getNoteVersion:[self authenticationToken]:guid:updateSequenceNum:withResourcesData:withResourcesRecognition:withResourcesAlternateData];
    } success:success failure:failure];
}

#pragma mark - NoteStore resource methods

- (void)getResourceWithGuid:(EDAMGuid)guid 
                   withData:(BOOL)withData 
            withRecognition:(BOOL)withRecognition 
             withAttributes:(BOOL)withAttributes 
          withAlternateDate:(BOOL)withAlternateData
                    success:(void(^)(EDAMResource *resource))success
                    failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResource:[self authenticationToken]:guid:withData:withRecognition:withAttributes:withAlternateData];
    } success:success failure:failure];
}

- (void)getResourceApplicationDataWithGuid:(EDAMGuid)guid
                                   success:(void(^)(EDAMLazyMap *map))success
                                   failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceApplicationData:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                            key:(NSString *)key
                                        success:(void(^)(NSString *entry))success
                                        failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceApplicationDataEntry:[self authenticationToken]:guid:key];
    } success:success failure:failure];
}

- (void)setResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                            key:(NSString *)key 
                                          value:(NSString *)value
                                        success:(void(^)(int32_t usn))success
                                        failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] setResourceApplicationDataEntry:[self authenticationToken]:guid:key:value];
    } success:success failure:failure];
}

- (void)unsetResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                              key:(NSString *)key
                                          success:(void(^)(int32_t usn))success
                                          failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] unsetResourceApplicationDataEntry:[self authenticationToken]:guid:key];
    } success:success failure:failure];
}

- (void)updateResource:(EDAMResource *)resource
               success:(void(^)(int32_t usn))success
               failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateResource:[self authenticationToken]:resource];
    } success:success failure:failure];
}

- (void)getResourceDataWithGuid:(EDAMGuid)guid
                        success:(void(^)(NSData *data))success
                        failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceData:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getResourceByHashWithGuid:(EDAMGuid)guid 
                      contentHash:(NSData *)contentHash 
                         withData:(BOOL)withData 
                  withRecognition:(BOOL)withRecognition 
                withAlternateData:(BOOL)withAlternateData
                          success:(void(^)(EDAMResource *resource))success
                          failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceByHash:[self authenticationToken]:guid:contentHash:withData:withRecognition:withAlternateData];
    } success:success failure:failure];
}

- (void)getResourceRecognitionWithGuid:(EDAMGuid)guid
                               success:(void(^)(NSData *data))success
                               failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceRecognition:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getResourceAlternateDataWithGuid:(EDAMGuid)guid
                                 success:(void(^)(NSData *data))success
                                 failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceAlternateData:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)getResourceAttributesWithGuid:(EDAMGuid)guid
                              success:(void(^)(EDAMResourceAttributes *attributes))success
                              failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getResourceAttributes:[self authenticationToken]:guid];
    } success:success failure:failure];
}

#pragma mark - NoteStore shared notebook methods

- (void)getPublicNotebookWithUserID:(EDAMUserID)userId 
                          publicUri:(NSString *)publicUri
                            success:(void(^)(EDAMNotebook *notebook))success
                            failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getPublicNotebook:userId:publicUri];
    } success:success failure:failure];
}

- (void)createSharedNotebook:(EDAMSharedNotebook *)sharedNotebook
                     success:(void(^)(EDAMSharedNotebook *sharedNotebook))success
                     failure:(void(^)(NSError *error))failure

{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createSharedNotebook:[self authenticationToken]:sharedNotebook];
    } success:success failure:failure];
}

- (void)sendMessageToSharedNotebookMembersWithGuid:(EDAMGuid)guid 
                                       messageText:(NSString *)messageText 
                                        recipients:(NSArray *)recipients
                                           success:(void(^)(int32_t numMessagesSent))success
                                           failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] sendMessageToSharedNotebookMembers:[self authenticationToken]:guid:messageText:recipients];
    } success:success failure:failure];
}

- (void)listSharedNotebooksWithSuccess:(void(^)(NSArray *sharedNotebooks))success
                               failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listSharedNotebooks:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)expungeSharedNotebooksWithIds:(NSArray *)sharedNotebookIds
                              success:(void(^)(int32_t usn))success
                              failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeSharedNotebooks:[self authenticationToken]:sharedNotebookIds];
    } success:success failure:failure];
}

- (void)createLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
                     success:(void(^)(EDAMLinkedNotebook *linkedNotebook))success
                     failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] createLinkedNotebook:[self authenticationToken]:linkedNotebook];
    } success:success failure:failure];
}

- (void)updateLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
                     success:(void(^)(int32_t usn))success
                     failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateLinkedNotebook:[self authenticationToken]:linkedNotebook];
    } success:success failure:failure];
}

- (void)listLinkedNotebooksWithSuccess:(void(^)(NSArray *linkedNotebooks))success
                               failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] listLinkedNotebooks:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)expungeLinkedNotebookWithGuid:(EDAMGuid)guid
                              success:(void(^)(int32_t usn))success
                              failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] expungeLinkedNotebook:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)authenticateToSharedNotebookWithShareKey:(NSString *)shareKey 
                                         success:(void(^)(EDAMAuthenticationResult *result))success
                                         failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] authenticateToSharedNotebook:[self authenticationToken]:shareKey];
    } success:success failure:failure];
}

- (void)getSharedNotebookByAuthWithSuccess:(void(^)(EDAMSharedNotebook *sharedNotebook))success
                                   failure:(void(^)(NSError *error))failure

{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] getSharedNotebookByAuth:[self authenticationToken]];
    } success:success failure:failure];
}

- (void)emailNoteWithParameters:(EDAMNoteEmailParameters *)parameters
                        success:(void(^)())success
                        failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncVoidBlock:^ {
        [[self currentNoteStore] emailNote:[self authenticationToken]:parameters];
    } success:success failure:failure];
}

- (void)shareNoteWithGuid:(EDAMGuid)guid
                  success:(void(^)(NSString *noteKey))success
                  failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] shareNote:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)stopSharingNoteWithGuid:(EDAMGuid)guid
                        success:(void(^)())success
                        failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncVoidBlock:^ {
        [[self currentNoteStore] stopSharingNote:[self authenticationToken]:guid];
    } success:success failure:failure];
}

- (void)authenticateToSharedNoteWithGuid:(NSString *)guid 
                                 noteKey:(NSString *)noteKey
                                 success:(void(^)(EDAMAuthenticationResult *result))success
                                 failure:(void(^)(NSError *error))failure
{
     [self invokeAsyncIdBlock:^id {
        return [[self currentNoteStore] authenticateToSharedNote:[self authenticationToken]:noteKey];
    } success:success failure:failure];
}

- (void)updateSharedNotebook:(EDAMSharedNotebook *)sharedNotebook
                     success:(void(^)(int32_t usn))success
                     failure:(void(^)(NSError *error))failure
{
    [self invokeAsyncInt32Block:^int32_t {
        return [[self currentNoteStore] updateSharedNotebook:[self authenticationToken] :sharedNotebook];
    } success:success failure:failure];
}

@end
