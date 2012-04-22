//
//  EvernoteNoteStore.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/20/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENAPI.h"

@interface EvernoteNoteStore : ENAPI

// Get an instance, using the shared EvernoteSession.
+ (EvernoteNoteStore *)noteStore;

// Construct an instance with the given session.
- (id)initWithSession:(EvernoteSession *)session;

// NoteStore sync methods
- (EDAMSyncState *)getSyncState;
- (EDAMSyncChunk *)getSyncChunkAfterUSN:(int32_t)afterUSN 
                             maxEntries:(int32_t)maxEntries
                           fullSyncOnly:(BOOL)fullSyncOnly;
- (EDAMSyncChunk *)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN
                                     maxEntries:(int32_t)maxEntries
                                         filter:(EDAMSyncChunkFilter *)filter;
- (EDAMSyncState *)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook;

// NoteStore notebook methods
- (NSArray *)listNotebooks;
- (EDAMNotebook *)getNotebookWithGuid:(EDAMGuid)guid;
- (EDAMSyncChunk *)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook
                                     afterUSN:(int32_t)afterUSN
                                   maxEntries:(int32_t) maxEntries
                                 fullSyncOnly:(BOOL)fullSyncOnly;
- (EDAMNotebook *)getDefaultNotebook;
- (EDAMNotebook *)createNotebook:(EDAMNotebook *)notebook;
- (int32_t)updateNotebook:(EDAMNotebook *)notebook;

// NoteStore tag methods
- (NSArray *)listTags;
- (NSArray *)listTagsByNotebookWithGuid:(EDAMGuid)guid;
- (EDAMTag *)getTagWithGuid:(EDAMGuid)guid;
- (EDAMTag *)createTag:(EDAMTag *)tag;
- (int32_t)updateTag:(EDAMTag *)tag;
- (void)untagAllWithGuid:(EDAMGuid)guid;

// NoteStore search methods
- (NSArray *)listSearches;
- (EDAMSavedSearch *)getSearchWithGuid:(EDAMGuid)guid;
- (EDAMSavedSearch *)createSearch:(EDAMSavedSearch *)search;
- (int32_t)updateSearch:(EDAMSavedSearch *)search;
- (int32_t)expungeSearchWithGuid:(EDAMGuid)guid;

// NoteStore notes methods
- (EDAMNoteList *)findNotesWithFilter:(EDAMNoteFilter *)filter 
                               offset:(int32_t)offset
                             maxNotes:(int32_t)maxNotes;
- (int32_t)findNoteOffsetWithFilter:(EDAMNoteFilter *)filter 
                               guid:(EDAMGuid)guid;
- (EDAMNotesMetadataList *)findNotesMetadataWithFilter:(EDAMNoteFilter *)filter
                                                offset:(int32_t)offset 
                                              maxNotes:(int32_t)maxNotes 
                                            resultSpec:(EDAMNotesMetadataResultSpec *)resultSpec;
- (EDAMNoteCollectionCounts *)findNoteCountsWithFilter:(EDAMNoteFilter *)filter 
                                             withTrash:(BOOL)withTrash;
- (EDAMNote *)getNoteWithGuid:(EDAMGuid)guid 
                  withContent:(BOOL)withContent 
            withResourcesData:(BOOL)withResourcesData 
     withResourcesRecognition:(BOOL)withResourcesRecognition 
   withResourcesAlternateData:(BOOL)withResourcesAlternateData;
- (EDAMLazyMap *)getNoteApplicationDataWithGuid:(EDAMGuid)guid;
- (NSString *)getNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                              key:(NSString *)key;
- (int32_t)setNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                           key:(NSString *)key 
                                         value:(NSString *)value;
- (int32_t)unsetNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                             key:(NSString *)key;
- (NSString *)getNoteContentWithGuid:(EDAMGuid)guid;
- (NSString *)getNoteSearchTextWithGuid:(EDAMGuid)guid 
                               noteOnly:(BOOL)noteOnly
                    tokenizeForIndexing:(BOOL)tokenizeForIndexing;
- (NSString *)getResourceSearchTextWithGuid:(EDAMGuid)guid;
- (NSArray *)getNoteTagNamesWithGuid:(EDAMGuid)guid;
- (EDAMNote *)createNote:(EDAMNote *)note;
- (EDAMNote *)updateNote:(EDAMNote *)note;
- (int32_t)deleteNoteWithGuid:(EDAMGuid)guid;
- (int32_t)expungeNoteWithGuid:(EDAMGuid)guid;
- (int32_t)expungeNotesWithGuids:(NSArray *)guids;
- (int32_t)expungeInactiveNotes;
- (EDAMNote *)copyNoteWithGuid:(EDAMGuid)guid 
        toNoteBookGuid:(EDAMGuid)toNotebookGuid;
- (NSArray *)listNoteVersionsWithGuid:(EDAMGuid)guid;
- (EDAMNote *)getNoteVersionWithGuid:(EDAMGuid)guid 
                   updateSequenceNum:(int32_t)updateSequenceNum 
                   withResourcesData:(BOOL)withResourcesData 
            withResourcesRecognition:(BOOL)withResourcesRecognition 
          withResourcesAlternateData:(BOOL)withResourcesAlternateData;

// NoteStore resource methods
- (EDAMResource *)getResourceWithGuid:(EDAMGuid)guid 
                             withData:(BOOL)withData 
                      withRecognition:(BOOL)withRecognition 
                       withAttributes:(BOOL)withAttributes 
                    withAlternateDate:(BOOL)withAlternateData;
- (EDAMLazyMap *)getResourceApplicationDataWithGuid:(EDAMGuid)guid;
- (NSString *)getResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                                  key:(NSString *)key;
- (int32_t)setResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                               key:(NSString *)key 
                                             value:(NSString *)value;
- (int32_t)unsetResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                                 key:(NSString *)key;
- (int32_t)updateResource:(EDAMResource *)resource;
- (NSData *)getResourceDataWithGuid:(EDAMGuid)guid;
- (EDAMResource *)getResourceByHashWithGuid:(EDAMGuid)guid 
                                contentHash:(NSData *)contentHash 
                                   withData:(BOOL)withData 
                            withRecognition:(BOOL)withRecognition 
                          withAlternateData:(BOOL)withAlternateData;
- (NSData *)getResourceRecognitionWithGuid:(EDAMGuid)guid;
- (NSData *)getResourceAlternateDataWithGuid:(EDAMGuid)guid;
- (EDAMResourceAttributes *)getResourceAttributesWithGuid:(EDAMGuid)guid;

// NoteStore ad methods
- (NSArray *)getAdsWithParameters:(EDAMAdParameters *)adParameters;
- (EDAMAd *)getRandomAdWithParameters:(EDAMAdParameters *)adParameters;

// NoteStore shared notebook methods
- (EDAMNotebook *)getPublicNotebookWithUserID:(EDAMUserID)userId 
                                    publicUri:(NSString *)publicUri;
- (EDAMSharedNotebook *)createSharedNotebook:(EDAMSharedNotebook *)sharedNotebook;
- (int32_t)sendMessageToSharedNotebookMembersWithGuid:(EDAMGuid)guid 
                                          messageText:(NSString *)messageText 
                                           recipients:(NSArray *)recipients;
- (NSArray *)listSharedNotebooks;
- (int32_t)expungeSharedNotebooksWithIds:(NSArray *)sharedNotebookIds;
- (EDAMLinkedNotebook *)createLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook;
- (int32_t)updateLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook;
- (NSArray *)listLinkedNotebooks;
- (int32_t)expungeLinkedNotebookWithGuid:(EDAMGuid)guid;
- (EDAMAuthenticationResult *)authenticateToSharedNotebookWithShareKey:(NSString *)shareKey;
- (EDAMSharedNotebook *)getSharedNotebookByAuth;
- (void)emailNoteWithParameters:(EDAMNoteEmailParameters *)parameters;
- (NSString *)shareNoteWithGuid:(EDAMGuid)guid;
- (void)stopSharingNoteWithGuid:(EDAMGuid)guid;
- (EDAMAuthenticationResult *)authenticateToSharedNoteWithGuid:(NSString *)guid 
                                                       noteKey:(NSString *)noteKey;

@end
