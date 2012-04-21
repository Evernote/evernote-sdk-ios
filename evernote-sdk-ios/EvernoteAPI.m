//
//  EvernoteAPI.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/20/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EDAM.h"
#import "EvernoteAPI.h"
#import "Thrift.h"

typedef void (^VoidBlock)();
typedef int32_t (^IntBlock)();
typedef NSObject *(^ObjBlock)();

@interface EvernoteAPI()

@property (nonatomic, retain) EvernoteSession *session;
@property (nonatomic, readonly) EDAMNoteStoreClient *noteStore;
@property (nonatomic, readonly) EDAMNoteStoreClient *userStore;

// fill in (possibly creating) an NSError from a given NSException.
- (void)populateNSError:(NSError **)error fromNSException:(NSException *)exception;

// "safe invoke" various blocks, with try/catch wrapping.
- (void)invokeVoidBlock:(void(^)())block withError:(NSError **)error;
- (int32_t)invokeIntBlock:(int32_t(^)())block withError:(NSError **)error;
- (NSObject *)invokeObjBlock:(NSObject *(^)())block withError:(NSError **)error;

@end

@implementation EvernoteAPI

@synthesize session = _session;
@dynamic noteStore;
@dynamic userStore;

+ (EvernoteAPI *)api
{
    EvernoteAPI *api = [[[EvernoteAPI alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    return api;
}

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

- (void)populateNSError:(NSError **)error fromNSException:(NSException *)exception
{
    if (exception) {
        int errorCode = kEvernoteSDKErrorNone;
        if ([exception respondsToSelector:@selector(errorCode)]) {
            // Evernote Thrift exception classes have an errorCode property
            errorCode = [(id)exception errorCode];
        }
        *error = [NSError errorWithDomain:kEvernoteSDKErrorDomain code:errorCode userInfo:exception.userInfo];
    }
}

- (void)invokeVoidBlock:(void(^)())block withError:(NSError **)error
{
    @try {
        block();
    }
    @catch (NSException *exception) {
        [self populateNSError:error fromNSException:exception];
    }
    @finally {
    }
}

- (int32_t)invokeIntBlock:(int32_t(^)())block withError:(NSError **)error
{
    int32_t retVal = 0;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateNSError:error fromNSException:exception];
    }
    @finally {
    }  
    return retVal;
}

- (NSObject *)invokeObjBlock:(NSObject *(^)())block withError:(NSError **)error
{
    NSObject *retVal = nil;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateNSError:error fromNSException:exception];
    }
    @finally {
    }  
    return retVal;   
}

#pragma mark - NoteStore sync methods

- (EDAMSyncState *)getSyncStateWithError:(NSError **)error 
{
    return (EDAMSyncState *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSyncState:self.session.authenticationToken];
    } withError:error];
}

- (EDAMSyncChunk *)getSyncChunkAfterUSN:(int32_t)afterUSN 
                             maxEntries:(int32_t)maxEntries
                           fullSyncOnly:(BOOL)fullSyncOnly
                                  error:(NSError **)error
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:fullSyncOnly];
    } withError:error];
}

- (EDAMSyncChunk *)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN
                                     maxEntries:(int32_t)maxEntries
                                         filter:(EDAMSyncChunkFilter *)filter
                                          error:(NSError **)error
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getFilteredSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:filter];
    } withError:error];
}

- (EDAMSyncState *)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook
                                        error:(NSError **)error
{
    return (EDAMSyncState *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getLinkedNotebookSyncState:self.session.authenticationToken:linkedNotebook];
    } withError:error];
}

#pragma mark - NoteStore notebook methods

- (NSArray *)listNotebooksWithError:(NSError **)error
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listNotebooks:self.session.authenticationToken];
    } withError:error];
}

- (EDAMNotebook *)getNotebookWithGuid:(EDAMGuid)guid 
                                error:(NSError **)error
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNotebook:self.session.authenticationToken:guid];
    } withError:error];
}

- (EDAMSyncChunk *)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook
                                     afterUSN:(int32_t)afterUSN
                                   maxEntries:(int32_t) maxEntries
                                 fullSyncOnly:(BOOL)fullSyncOnly
                                        error:(NSError **)error
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getLinkedNotebookSyncChunk:self.session.authenticationToken:linkedNotebook:afterUSN:maxEntries:fullSyncOnly];
    } withError:error];
}

- (EDAMNotebook *)getDefaultNotebookWithError:(NSError **)error
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getDefaultNotebook:self.session.authenticationToken];
    } withError:error];
}

- (EDAMNotebook *)createNotebook:(EDAMNotebook *)notebook
                           error:(NSError **)error
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createNotebook:self.session.authenticationToken:notebook];
    } withError:error];
}

- (int32_t)updateNotebook:(EDAMNotebook *)notebook
                    error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore updateNotebook:self.session.authenticationToken:notebook];
    } withError:error];
}

- (int32_t)expungeNotebookWithGuid:(EDAMGuid)guid
                             error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeNotebook:self.session.authenticationToken:guid];
    } withError:error];
}

#pragma mark - NoteStore tags methods

- (NSArray *)listTagsWithError:(NSError **)error
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listTags:self.session.authenticationToken];
    } withError:error];
}

- (NSArray *)listTagsByNotebookWithGuid:(EDAMGuid)notebookGuid
                                  error:(NSError **)error
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listTagsByNotebook:self.session.authenticationToken:notebookGuid];
    } withError:error]; 
};

- (EDAMTag *)getTagWithGuid:(EDAMGuid)guid
                      error:(NSError **)error
{
    return (EDAMTag *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getTag:self.session.authenticationToken:guid];
    } withError:error]; 
}

- (EDAMTag *)createTag:(EDAMTag *)tag
                 error:(NSError **)error
{
    return (EDAMTag *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createTag:self.session.authenticationToken:tag];
    } withError:error]; 
}

- (int32_t)updateTag:(EDAMTag *)tag
               error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore updateTag:self.session.authenticationToken:tag];
    } withError:error];
}

- (void)untagAllWithGuid:(EDAMGuid)guid
                   error:(NSError **)error
{
    [self invokeVoidBlock:^() {
        [self.noteStore untagAll:self.session.authenticationToken:guid];
    } withError:error];
}

- (int32_t)expungeTagWithGuid:(EDAMGuid)guid
                        error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeTag:self.session.authenticationToken:guid];
    } withError:error];    
}

#pragma mark - NoteStore search methods

- (NSArray *)listSearchesWithError:(NSError **)error
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listSearches:self.session.authenticationToken];
    } withError:error];
}

- (EDAMSavedSearch *)getSearchWithGuid:(EDAMGuid)guid
                                 error:(NSError **)error
{
    return (EDAMSavedSearch *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSearch:self.session.authenticationToken:guid];
    } withError:error];
}

- (EDAMSavedSearch *)createSearch:(EDAMSavedSearch *)search
                            error:(NSError **)error
{
    return (EDAMSavedSearch *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createSearch:self.session.authenticationToken:search];
    } withError:error];    
}

- (int32_t)updateSearch:(EDAMSavedSearch *)search
                  error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore updateSearch:self.session.authenticationToken:search];
    } withError:error]; 
}

- (int32_t)expungeSearchWithGuid:(EDAMGuid)guid
                           error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeSearch:self.session.authenticationToken:guid];
    } withError:error]; 
}

#pragma mark - notes methods

- (EDAMNoteList *)findNotesWithFilter:(EDAMNoteFilter *)filter 
                               offset:(int32_t)offset
                             maxNotes:(int32_t)maxNotes
                                error:(NSError **)error
{
    return (EDAMNoteList *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore findNotes:self.session.authenticationToken:filter:offset:maxNotes];
    } withError:error];   
}

- (int32_t)findNoteOffsetWithFilter:(EDAMNoteFilter *)filter 
                               guid:(EDAMGuid)guid
                              error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore findNoteOffset:self.session.authenticationToken:filter:guid];
    } withError:error]; 

}

- (EDAMNotesMetadataList *)findNotesMetadataWithFilter:(EDAMNoteFilter *)filter
                                                offset:(int32_t)offset 
                                              maxNotes:(int32_t)maxNotes 
                                            resultSpec:(EDAMNotesMetadataResultSpec *)resultSpec
                                                 error:(NSError **)error
{
    return (EDAMNotesMetadataList *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore findNotesMetadata:self.session.authenticationToken:filter:offset:maxNotes:resultSpec];
    } withError:error];   
}

- (EDAMNoteCollectionCounts *)findNoteCountsWithFilter:(EDAMNoteFilter *)filter 
                                             withTrash:(BOOL)withTrash
                                                 error:(NSError **)error
{
    return (EDAMNoteCollectionCounts *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore findNoteCounts:self.session.authenticationToken:filter:withTrash];
    } withError:error];
}

- (EDAMNote *)getNoteWithGuid:(EDAMGuid)guid 
                  withContent:(BOOL)withContent 
             withResourcesData:(BOOL)withResourcesData 
     withResourcesRecognition:(BOOL)withResourcesRecognition 
   withResourcesAlternateData:(BOOL)withResourcesAlternateData
                        error:(NSError **)error
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNote:self.session.authenticationToken:guid:withContent:withResourcesData:withResourcesRecognition:withResourcesAlternateData];
    } withError:error];
}

- (EDAMLazyMap *)getNoteApplicationDataWithGuid:(EDAMGuid)guid
                                          error:(NSError **)error
{
    return (EDAMLazyMap *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteApplicationData:self.session.authenticationToken:guid];
    } withError:error];
}

- (NSString *)getNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                              key:(NSString *)key
                                            error:(NSError **)error
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteApplicationDataEntry:self.session.authenticationToken:guid:key];
    } withError:error];
}

- (int32_t)setNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                           key:(NSString *)key 
                                         value:(NSString *)value
                                         error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore setNoteApplicationDataEntry:self.session.authenticationToken:guid:key:value];
    } withError:error]; 
}

- (int32_t)unsetNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                             key:(NSString *) key
                                           error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore unsetNoteApplicationDataEntry:self.session.authenticationToken:guid:key];
    } withError:error]; 
}

- (NSString *)getNoteContentWithGuid:(EDAMGuid)guid
                               error:(NSError **)error
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteContent:self.session.authenticationToken:guid];
    } withError:error];
}

- (NSString *)getNoteSearchTextWithGuid:(EDAMGuid)guid 
                               noteOnly:(BOOL)noteOnly
                    tokenizeForIndexing:(BOOL)tokenizeForIndexing
                                  error:(NSError **)error
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteSearchText:self.session.authenticationToken:guid:noteOnly:tokenizeForIndexing];
    } withError:error];
}

- (NSString *)getResourceSearchTextWithGuid:(EDAMGuid)guid
                                      error:(NSError **)error
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceSearchText:self.session.authenticationToken:guid];
    } withError:error];
}

- (NSArray *)getNoteTagNamesWithGuid:(EDAMGuid)guid
                               error:(NSError **)error
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteTagNames:self.session.authenticationToken:guid];
    } withError:error];
}

- (EDAMNote *)createNote:(EDAMNote *)note
                   error:(NSError **)error
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createNote:self.session.authenticationToken:note];
    } withError:error];
}

- (EDAMNote *)updateNote:(EDAMNote *)note
                   error:(NSError **)error
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore updateNote:self.session.authenticationToken:note];
    } withError:error];
}

- (int32_t)deleteNoteWithGuid:(EDAMGuid)guid
                        error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore deleteNote:self.session.authenticationToken:guid];
    } withError:error]; 
}

- (int32_t)expungeNoteWithGuid:(EDAMGuid)guid
                         error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeNote:self.session.authenticationToken:guid];
    } withError:error]; 
}

- (int32_t)expungeNotesWithGuids:(NSArray *)noteGuids
                           error:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeNotes:self.session.authenticationToken:noteGuids];
    } withError:error]; 
}

- (int32_t)expungeInactiveNotesWithError:(NSError **)error
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeInactiveNotes:self.session.authenticationToken];
    } withError:error];     
}

- (EDAMNote *)copyNote:(EDAMNote *)copyNote
              noteGuid:(EDAMGuid)noteGuid 
        toNoteBookGuid:(EDAMGuid)toNotebookGuid
                 error:(NSError **)error
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore copyNote:self.session.authenticationToken:noteGuid:toNotebookGuid];
    } withError:error];
}

- (NSArray *)listNoteVersionsWithGuid:(EDAMGuid)noteGuid
                                error:(NSError **)error
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listNoteVersions:self.session.authenticationToken:noteGuid];
    } withError:error];
}

- (EDAMNote *)getNoteVersionWithNoteGuid:(EDAMGuid)noteGuid 
                       updateSequenceNum:(int32_t)updateSequenceNum 
                        withResourcesData:(BOOL)withResourcesData 
                withResourcesRecognition:(BOOL)withResourcesRecognition 
              withResourcesAlternateData:(BOOL)withResourcesAlternateData
                                   error:(NSError **)error
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteVersion:self.session.authenticationToken:noteGuid:updateSequenceNum:withResourcesData:withResourcesRecognition:withResourcesAlternateData];
    } withError:error];
}

@end
