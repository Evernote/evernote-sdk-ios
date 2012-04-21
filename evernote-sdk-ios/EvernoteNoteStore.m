//
//  EvernoteNoteStore.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/20/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EDAM.h"
#import "EvernoteNoteStore.h"
#import "Thrift.h"

typedef void (^VoidBlock)();
typedef int32_t (^IntBlock)();
typedef NSObject *(^ObjBlock)();

@interface EvernoteNoteStore()

@property (nonatomic, retain) EvernoteSession *session;
@property (nonatomic, readonly) EDAMNoteStoreClient *noteStore;
@property (nonatomic, readonly) EDAMNoteStoreClient *userStore;

// set our error property from a given NSException.
- (void)populateErrorFromNSException:(NSException *)exception;

// "safe invoke" various blocks, with try/catch wrapping.
- (void)invokeVoidBlock:(void(^)())block;
- (int32_t)invokeIntBlock:(int32_t(^)())block;
- (NSObject *)invokeObjBlock:(NSObject *(^)())block;

@end

@implementation EvernoteNoteStore

@synthesize session = _session;
@synthesize error = _error;
@dynamic noteStore;
@dynamic userStore;

+ (EvernoteNoteStore *)noteStore
{
    EvernoteNoteStore *noteStore = [[[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    return noteStore;
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

- (void)populateErrorFromNSException:(NSException *)exception
{
    if (exception) {
        int errorCode = EDAMErrorCode_UNKNOWN;
        if ([exception respondsToSelector:@selector(errorCode)]) {
            // Evernote Thrift exception classes have an errorCode property
            errorCode = [(id)exception errorCode];
        }
        self.error = [NSError errorWithDomain:kEvernoteSDKErrorDomain code:errorCode userInfo:exception.userInfo];
    }
}

- (void)invokeVoidBlock:(void(^)())block
{
    self.error = nil;
    @try {
        block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }
}

- (int32_t)invokeIntBlock:(int32_t(^)())block
{
    self.error = nil;
    int32_t retVal = 0;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }  
    return retVal;
}

- (NSObject *)invokeObjBlock:(NSObject *(^)())block
{
    self.error = nil;
    NSObject *retVal = nil;
    @try {
        retVal = block();
    }
    @catch (NSException *exception) {
        [self populateErrorFromNSException:exception];
    }
    @finally {
    }  
    return retVal;   
}

#pragma mark - NoteStore sync methods

- (EDAMSyncState *)getSyncState 
{
    return (EDAMSyncState *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSyncState:self.session.authenticationToken];
    }];
}

- (EDAMSyncChunk *)getSyncChunkAfterUSN:(int32_t)afterUSN 
                             maxEntries:(int32_t)maxEntries
                           fullSyncOnly:(BOOL)fullSyncOnly

{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:fullSyncOnly];
    }];
}

- (EDAMSyncChunk *)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN
                                     maxEntries:(int32_t)maxEntries
                                         filter:(EDAMSyncChunkFilter *)filter
        
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getFilteredSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:filter];
    }];
}

- (EDAMSyncState *)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook
      
{
    return (EDAMSyncState *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getLinkedNotebookSyncState:self.session.authenticationToken:linkedNotebook];
    }];
}

#pragma mark - NoteStore notebook methods

- (NSArray *)listNotebooks
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listNotebooks:self.session.authenticationToken];
    }];
}

- (EDAMNotebook *)getNotebookWithGuid:(EDAMGuid)guid 
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNotebook:self.session.authenticationToken:guid];
    }];
}

- (EDAMSyncChunk *)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook
                                     afterUSN:(int32_t)afterUSN
                                   maxEntries:(int32_t) maxEntries
                                 fullSyncOnly:(BOOL)fullSyncOnly
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getLinkedNotebookSyncChunk:self.session.authenticationToken:linkedNotebook:afterUSN:maxEntries:fullSyncOnly];
    }];
}

- (EDAMNotebook *)getDefaultNotebook
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getDefaultNotebook:self.session.authenticationToken];
    }];
}

- (EDAMNotebook *)createNotebook:(EDAMNotebook *)notebook
                           
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createNotebook:self.session.authenticationToken:notebook];
    }];
}

- (int32_t)updateNotebook:(EDAMNotebook *)notebook
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore updateNotebook:self.session.authenticationToken:notebook];
    }];
}

- (int32_t)expungeNotebookWithGuid:(EDAMGuid)guid
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeNotebook:self.session.authenticationToken:guid];
    }];
}

#pragma mark - NoteStore tags methods

- (NSArray *)listTags
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listTags:self.session.authenticationToken];
    }];
}

- (NSArray *)listTagsByNotebookWithGuid:(EDAMGuid)notebookGuid
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listTagsByNotebook:self.session.authenticationToken:notebookGuid];
    }]; 
};

- (EDAMTag *)getTagWithGuid:(EDAMGuid)guid
{
    return (EDAMTag *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getTag:self.session.authenticationToken:guid];
    }]; 
}

- (EDAMTag *)createTag:(EDAMTag *)tag
{
    return (EDAMTag *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createTag:self.session.authenticationToken:tag];
    }]; 
}

- (int32_t)updateTag:(EDAMTag *)tag
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore updateTag:self.session.authenticationToken:tag];
    }];
}

- (void)untagAllWithGuid:(EDAMGuid)guid
{
    [self invokeVoidBlock:^() {
        [self.noteStore untagAll:self.session.authenticationToken:guid];
    }];
}

- (int32_t)expungeTagWithGuid:(EDAMGuid)guid
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeTag:self.session.authenticationToken:guid];
    }];    
}

#pragma mark - NoteStore search methods

- (NSArray *)listSearches
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listSearches:self.session.authenticationToken];
    }];
}

- (EDAMSavedSearch *)getSearchWithGuid:(EDAMGuid)guid
{
    return (EDAMSavedSearch *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSearch:self.session.authenticationToken:guid];
    }];
}

- (EDAMSavedSearch *)createSearch:(EDAMSavedSearch *)search
                            
{
    return (EDAMSavedSearch *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createSearch:self.session.authenticationToken:search];
    }];    
}

- (int32_t)updateSearch:(EDAMSavedSearch *)search
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore updateSearch:self.session.authenticationToken:search];
    }]; 
}

- (int32_t)expungeSearchWithGuid:(EDAMGuid)guid
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeSearch:self.session.authenticationToken:guid];
    }]; 
}

#pragma mark - notes methods

- (EDAMNoteList *)findNotesWithFilter:(EDAMNoteFilter *)filter 
                               offset:(int32_t)offset
                             maxNotes:(int32_t)maxNotes
{
    return (EDAMNoteList *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore findNotes:self.session.authenticationToken:filter:offset:maxNotes];
    }];   
}

- (int32_t)findNoteOffsetWithFilter:(EDAMNoteFilter *)filter 
                               guid:(EDAMGuid)guid
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore findNoteOffset:self.session.authenticationToken:filter:guid];
    }]; 

}

- (EDAMNotesMetadataList *)findNotesMetadataWithFilter:(EDAMNoteFilter *)filter
                                                offset:(int32_t)offset 
                                              maxNotes:(int32_t)maxNotes 
                                            resultSpec:(EDAMNotesMetadataResultSpec *)resultSpec
{
    return (EDAMNotesMetadataList *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore findNotesMetadata:self.session.authenticationToken:filter:offset:maxNotes:resultSpec];
    }];   
}

- (EDAMNoteCollectionCounts *)findNoteCountsWithFilter:(EDAMNoteFilter *)filter 
                                             withTrash:(BOOL)withTrash
{
    return (EDAMNoteCollectionCounts *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore findNoteCounts:self.session.authenticationToken:filter:withTrash];
    }];
}

- (EDAMNote *)getNoteWithGuid:(EDAMGuid)guid 
                  withContent:(BOOL)withContent 
             withResourcesData:(BOOL)withResourcesData 
     withResourcesRecognition:(BOOL)withResourcesRecognition 
   withResourcesAlternateData:(BOOL)withResourcesAlternateData
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNote:self.session.authenticationToken:guid:withContent:withResourcesData:withResourcesRecognition:withResourcesAlternateData];
    }];
}

- (EDAMLazyMap *)getNoteApplicationDataWithGuid:(EDAMGuid)guid
{
    return (EDAMLazyMap *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteApplicationData:self.session.authenticationToken:guid];
    }];
}

- (NSString *)getNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                              key:(NSString *)key
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteApplicationDataEntry:self.session.authenticationToken:guid:key];
    }];
}

- (int32_t)setNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                           key:(NSString *)key 
                                         value:(NSString *)value
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore setNoteApplicationDataEntry:self.session.authenticationToken:guid:key:value];
    }]; 
}

- (int32_t)unsetNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                             key:(NSString *) key
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore unsetNoteApplicationDataEntry:self.session.authenticationToken:guid:key];
    }]; 
}

- (NSString *)getNoteContentWithGuid:(EDAMGuid)guid
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteContent:self.session.authenticationToken:guid];
    }];
}

- (NSString *)getNoteSearchTextWithGuid:(EDAMGuid)guid 
                               noteOnly:(BOOL)noteOnly
                    tokenizeForIndexing:(BOOL)tokenizeForIndexing
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteSearchText:self.session.authenticationToken:guid:noteOnly:tokenizeForIndexing];
    }];
}

- (NSString *)getResourceSearchTextWithGuid:(EDAMGuid)guid
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceSearchText:self.session.authenticationToken:guid];
    }];
}

- (NSArray *)getNoteTagNamesWithGuid:(EDAMGuid)guid
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteTagNames:self.session.authenticationToken:guid];
    }];
}

- (EDAMNote *)createNote:(EDAMNote *)note
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createNote:self.session.authenticationToken:note];
    }];
}

- (EDAMNote *)updateNote:(EDAMNote *)note
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore updateNote:self.session.authenticationToken:note];
    }];
}

- (int32_t)deleteNoteWithGuid:(EDAMGuid)guid
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore deleteNote:self.session.authenticationToken:guid];
    }]; 
}

- (int32_t)expungeNoteWithGuid:(EDAMGuid)guid
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeNote:self.session.authenticationToken:guid];
    }]; 
}

- (int32_t)expungeNotesWithGuids:(NSArray *)noteGuids
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeNotes:self.session.authenticationToken:noteGuids];
    }]; 
}

- (int32_t)expungeInactiveNotes
{
    return [self invokeIntBlock:^int32_t() {
        return [self.noteStore expungeInactiveNotes:self.session.authenticationToken];
    }];     
}

- (EDAMNote *)copyNote:(EDAMNote *)copyNote
              noteGuid:(EDAMGuid)noteGuid 
        toNoteBookGuid:(EDAMGuid)toNotebookGuid
                 
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore copyNote:self.session.authenticationToken:noteGuid:toNotebookGuid];
    }];
}

- (NSArray *)listNoteVersionsWithGuid:(EDAMGuid)noteGuid
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listNoteVersions:self.session.authenticationToken:noteGuid];
    }];
}

- (EDAMNote *)getNoteVersionWithNoteGuid:(EDAMGuid)noteGuid 
                       updateSequenceNum:(int32_t)updateSequenceNum 
                        withResourcesData:(BOOL)withResourcesData 
                withResourcesRecognition:(BOOL)withResourcesRecognition 
              withResourcesAlternateData:(BOOL)withResourcesAlternateData
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteVersion:self.session.authenticationToken:noteGuid:updateSequenceNum:withResourcesData:withResourcesRecognition:withResourcesAlternateData];
    }];
}

@end
