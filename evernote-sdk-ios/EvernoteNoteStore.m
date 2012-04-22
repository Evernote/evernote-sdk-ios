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


@interface EvernoteNoteStore()

@end

@implementation EvernoteNoteStore

+ (EvernoteNoteStore *)noteStore
{
    EvernoteNoteStore *noteStore = [[[EvernoteNoteStore alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
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
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore updateNotebook:self.session.authenticationToken:notebook];
    }];
}

- (int32_t)expungeNotebookWithGuid:(EDAMGuid)guid
{
    return [self invokeInt32Block:^int32_t() {
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
    return [self invokeInt32Block:^int32_t() {
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
    return [self invokeInt32Block:^int32_t() {
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
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore updateSearch:self.session.authenticationToken:search];
    }]; 
}

- (int32_t)expungeSearchWithGuid:(EDAMGuid)guid
{
    return [self invokeInt32Block:^int32_t() {
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
    return [self invokeInt32Block:^int32_t() {
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
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore setNoteApplicationDataEntry:self.session.authenticationToken:guid:key:value];
    }]; 
}

- (int32_t)unsetNoteApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                             key:(NSString *) key
{
    return [self invokeInt32Block:^int32_t() {
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
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore deleteNote:self.session.authenticationToken:guid];
    }]; 
}

- (int32_t)expungeNoteWithGuid:(EDAMGuid)guid
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore expungeNote:self.session.authenticationToken:guid];
    }]; 
}

- (int32_t)expungeNotesWithGuids:(NSArray *)guids
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore expungeNotes:self.session.authenticationToken:guids];
    }]; 
}

- (int32_t)expungeInactiveNotes
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore expungeInactiveNotes:self.session.authenticationToken];
    }];     
}

- (EDAMNote *)copyNoteWithGuid:(EDAMGuid)guid 
                toNoteBookGuid:(EDAMGuid)toNotebookGuid
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore copyNote:self.session.authenticationToken:guid:toNotebookGuid];
    }];
}

- (NSArray *)listNoteVersionsWithGuid:(EDAMGuid)guid
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listNoteVersions:self.session.authenticationToken:guid];
    }];
}

- (EDAMNote *)getNoteVersionWithGuid:(EDAMGuid)guid 
                   updateSequenceNum:(int32_t)updateSequenceNum 
                   withResourcesData:(BOOL)withResourcesData 
            withResourcesRecognition:(BOOL)withResourcesRecognition 
          withResourcesAlternateData:(BOOL)withResourcesAlternateData
{
    return (EDAMNote *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNoteVersion:self.session.authenticationToken:guid:updateSequenceNum:withResourcesData:withResourcesRecognition:withResourcesAlternateData];
    }];
}

#pragma mark - NoteStore resource methods

- (EDAMResource *)getResourceWithGuid:(EDAMGuid)guid 
                             withData:(BOOL)withData 
                      withRecognition:(BOOL)withRecognition 
                       withAttributes:(BOOL)withAttributes 
                    withAlternateDate:(BOOL)withAlternateData
{
    return (EDAMResource *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResource:self.session.authenticationToken:guid:withData:withRecognition:withAttributes:withAlternateData];
    }];
}

- (EDAMLazyMap *)getResourceApplicationDataWithGuid:(EDAMGuid)guid
{
    return (EDAMLazyMap *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceApplicationData:self.session.authenticationToken:guid];
    }];
}

- (NSString *)getResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                                  key:(NSString *)key
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceApplicationDataEntry:self.session.authenticationToken:guid:key];
    }];
}

- (int32_t)setResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                               key:(NSString *)key 
                                             value:(NSString *)value
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore setResourceApplicationDataEntry:self.session.authenticationToken:guid:key:value];
    }];
}

- (int32_t)unsetResourceApplicationDataEntryWithGuid:(EDAMGuid)guid 
                                                 key:(NSString *)key
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore unsetResourceApplicationDataEntry:self.session.authenticationToken:guid:key];
    }];
}

- (int32_t)updateResource:(EDAMResource *)resource
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore updateResource:self.session.authenticationToken:resource];
    }];
}

- (NSData *)getResourceDataWithGuid:(EDAMGuid)guid
{
    return (NSData *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceData:self.session.authenticationToken:guid];
    }];
}

- (EDAMResource *)getResourceByHashWithGuid:(EDAMGuid)guid 
                                contentHash:(NSData *)contentHash 
                                   withData:(BOOL)withData 
                            withRecognition:(BOOL)withRecognition 
                          withAlternateData:(BOOL)withAlternateData
{
    return (EDAMResource *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceByHash:self.session.authenticationToken:guid:contentHash:withData:withRecognition:withAlternateData];
    }]; 
}

- (NSData *)getResourceRecognitionWithGuid:(EDAMGuid)guid
{
    return (NSData *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceRecognition:self.session.authenticationToken:guid];
    }];
}

- (NSData *)getResourceAlternateDataWithGuid:(EDAMGuid)guid
{
    return (NSData *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceAlternateData:self.session.authenticationToken:guid];
    }]; 
}

- (EDAMResourceAttributes *)getResourceAttributesWithGuid:(EDAMGuid)guid
{
    return (EDAMResourceAttributes *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getResourceAttributes:self.session.authenticationToken:guid];
    }]; 
}

#pragma mark - NoteStore account methods

- (int64_t)getAccountSize
{
    return [self invokeInt64Block:^int64_t() {
        return [self.noteStore getAccountSize:self.session.authenticationToken];
    }];
}

#pragma mark - NoteStore ad methods

#warning adParameters or parameters?
- (NSArray *)getAdsWithParameters:(EDAMAdParameters *)adParameters
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getAds:self.session.authenticationToken:adParameters];
    }]; 

}

- (EDAMAd *)getRandomAdWithParameters:(EDAMAdParameters *)adParameters
{
    return (EDAMAd *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getRandomAd:self.session.authenticationToken:adParameters];
    }]; 
}

#pragma mark - NoteStore shared notebook methods

- (EDAMNotebook *)getPublicNotebookWithUserID:(EDAMUserID)userId 
                                    publicUri:(NSString *)publicUri
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getPublicNotebook:userId:publicUri];
    }]; 
}

- (EDAMSharedNotebook *)createSharedNotebook:(EDAMSharedNotebook *)sharedNotebook
{
    return (EDAMSharedNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createSharedNotebook:self.session.authenticationToken:sharedNotebook];
    }]; 
}

#warning withGuid or withNotebookGuid?
- (int32_t)sendMessageToSharedNotebookMembersWithGuid:(EDAMGuid)notebookGuid 
                                          messageText:(NSString *)messageText 
                                           recipients:(NSArray *)recipients
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore sendMessageToSharedNotebookMembers:self.session.authenticationToken:notebookGuid:messageText:recipients];
    }];
}

- (NSArray *)listSharedNotebooks
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listSharedNotebooks:self.session.authenticationToken];
    }]; 
}

#warning are these GUIDs?
- (int32_t)expungeSharedNotebooksWithIds:(NSArray *)sharedNotebookIds
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore expungeSharedNotebooks:self.session.authenticationToken:sharedNotebookIds];
    }];
}

- (EDAMLinkedNotebook *)createLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
{
    return (EDAMLinkedNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createLinkedNotebook:self.session.authenticationToken:linkedNotebook];
    }];
}

- (int32_t)updateLinkedNotebook:(EDAMLinkedNotebook *)linkedNotebook
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore updateLinkedNotebook:self.session.authenticationToken:linkedNotebook];
    }]; 
}

- (NSArray *)listLinkedNotebooks
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listLinkedNotebooks:self.session.authenticationToken];
    }];  
}

- (int32_t)expungeLinkedNotebookWithGuid:(EDAMGuid)guid
{
    return [self invokeInt32Block:^int32_t() {
        return [self.noteStore expungeLinkedNotebook:self.session.authenticationToken:guid];
    }];
}

- (EDAMAuthenticationResult *)authenticateToSharedNotebookWithShareKey:(NSString *)shareKey 
{
    return (EDAMAuthenticationResult *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore authenticateToSharedNotebook:self.session.authenticationToken:shareKey];
    }]; 
}

- (EDAMSharedNotebook *)getSharedNotebookByAuth
{
    return (EDAMSharedNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSharedNotebookByAuth:self.session.authenticationToken];
    }]; 
}

- (void)emailNoteWithParameters:(EDAMNoteEmailParameters *)parameters
{
    [self invokeVoidBlock:^() {
        [self.noteStore emailNote:self.session.authenticationToken:parameters];
    }];
}

- (NSString *)shareNoteWithGuid:(EDAMGuid)guid
{
    return (NSString *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore shareNote:self.session.authenticationToken:guid];
    }]; 
}

- (void)stopSharingNoteWithGuid:(EDAMGuid)guid
{
    [self invokeVoidBlock:^() {
        [self.noteStore stopSharingNote:self.session.authenticationToken:guid];
    }];
}

- (EDAMAuthenticationResult *)authenticateToSharedNoteWithGuid:(NSString *)guid 
                                                       noteKey:(NSString *)noteKey
{
    return (EDAMAuthenticationResult *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore authenticateToSharedNote:self.session.authenticationToken:noteKey];
    }]; 
}

@end
