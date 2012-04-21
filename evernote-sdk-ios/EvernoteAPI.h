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
- (NSArray *)listTagsWithError:(NSError **)error;
- (NSArray *)listTagsByNotebookWithGuid:(EDAMGuid)notebookGuid
                                  error:(NSError **)error;
- (EDAMTag *)getTagWithGuid:(EDAMGuid)guid
                      error:(NSError **)error;
- (EDAMTag *)createTag:(EDAMTag *)tag
                 error:(NSError **)error;
- (int32_t)updateTag:(EDAMTag *)tag
               error:(NSError **)error;
- (void)untagAllWithGuid:(EDAMGuid)guid
                   error:(NSError **)error;

// NoteStore search methods
- (NSArray *)listSearchesWithError:(NSError **)error;
- (EDAMSavedSearch *)getSearchWithGuid:(EDAMGuid)guid
                                 error:(NSError **)error;
- (EDAMSavedSearch *)createSearch:(EDAMSavedSearch *)search
                            error:(NSError **)error;
- (int32_t)updateSearch:(EDAMSavedSearch *)search
                  error:(NSError **)error;
- (int32_t)expungeSearchWithGuid:(EDAMGuid)guid
                           error:(NSError **)error;

// NoteStore notes methods
- (EDAMNoteList *)findNotesWithFilter:(EDAMNoteFilter *)filter 
                               offset:(int32_t)offset
                             maxNotes:(int32_t)maxNotes
                                error:(NSError **)error;
- (int32_t)findNoteOffsetWithFilter:(EDAMNoteFilter *)filter 
                               guid:(EDAMGuid)guid
                              error:(NSError **)error;
- (EDAMNotesMetadataList *)findNotesMetadataWithFilter:(EDAMNoteFilter *)filter
                                                offset:(int32_t)offset 
                                              maxNotes:(int32_t)maxNotes 
                                            resultSpec:(EDAMNotesMetadataResultSpec *)resultSpec
                                                 error:(NSError **)error;
- (EDAMNoteCollectionCounts *)findNoteCountsWithFilter:(EDAMNoteFilter *)filter 
                                             withTrash:(BOOL)withTrash
                                                 error:(NSError **)error;
- (EDAMNote *)getNoteWithGuid:(EDAMGuid)guid 
                  withContent:(BOOL)withContent 
            withResourcesData:(BOOL)withResourcesData 
     withResourcesRecognition:(BOOL)withResourcesRecognition 
   withResourcesAlternateData:(BOOL)withResourcesAlternateData
                        error:(NSError **)error;
- (EDAMLazyMap *)getNoteApplicationDataWithGuid:(EDAMGuid)guid
                                          error:(NSError **)error;
- (NSString *)getNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                              key:(NSString *)key
                                            error:(NSError **)error;
- (int32_t)setNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                           key:(NSString *)key 
                                         value:(NSString *)value
                                         error:(NSError **)error;
- (int32_t)unsetNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                             key:(NSString *) key
                                           error:(NSError **)error;
- (NSString *)getNoteContentWithGuid:(EDAMGuid)guid
                               error:(NSError **)error;
- (NSString *)getNoteSearchTextWithGuid:(EDAMGuid)guid 
                               noteOnly:(BOOL)noteOnly
                    tokenizeForIndexing:(BOOL)tokenizeForIndexing
                                  error:(NSError **)error;
- (NSString *)getResourceSearchTextWithGuid:(EDAMGuid)guid
                                      error:(NSError **)error;
- (NSArray *)getNoteTagNamesWithGuid:(EDAMGuid)guid
                               error:(NSError **)error;
- (EDAMNote *)createNote:(EDAMNote *)note
                   error:(NSError **)error;
- (EDAMNote *)updateNote:(EDAMNote *)note
                   error:(NSError **)error;
- (int32_t)deleteNoteWithGuid:(EDAMGuid)guid
                        error:(NSError **)error;
- (int32_t)expungeNoteWithGuid:(EDAMGuid)guid
                         error:(NSError **)error;
- (int32_t)expungeNotesWithGuids:(NSArray *)noteGuids
                           error:(NSError **)error;
- (int32_t)expungeInactiveNotesWithError:(NSError **)error;
- (EDAMNote *)copyNote:(EDAMNote *)copyNote
              noteGuid:(EDAMGuid)noteGuid 
        toNoteBookGuid:(EDAMGuid)toNotebookGuid
                 error:(NSError **)error;
- (NSArray *)listNoteVersionsWithGuid:(EDAMGuid)noteGuid
                                error:(NSError **)error;
- (EDAMNote *)getNoteVersionWithNoteGuid:(EDAMGuid)noteGuid 
                       updateSequenceNum:(int32_t)updateSequenceNum 
                       withResourcesData:(BOOL)withResourcesData 
                withResourcesRecognition:(BOOL)withResourcesRecognition 
              withResourcesAlternateData:(BOOL)withResourcesAlternateData
                                   error:(NSError **)error;

@end
