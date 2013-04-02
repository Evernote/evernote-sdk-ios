/*
 * EvernoteNoteStore+Extras.m
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

#import "EvernoteNoteStore+Extras.h"
#import "EDAMNoteStoreClient+Utilities.h"
#import "EDAMTypes.h"
#import "ENApplicationBridge.h"
#import "ENApplicationBridge_Private.h"
#import "EvernoteUserStore.h"

@implementation EvernoteNoteStore (Extras)

#pragma mark - Shared notes

- (void)listNotesForLinkedNotebook:(EDAMLinkedNotebook*)linkedNotebook
                              withFilter:(EDAMNoteFilter *)filter
                                 success:(void(^)(EDAMNoteList *list))success
                                 failure:(void(^)(NSError *error))failure {
    // Get the note store corresponding to this shared note
    EvernoteNoteStore* sharedNoteStore = [EvernoteNoteStore noteStoreForLinkedNotebook:linkedNotebook];
    // Get the shared notebook, for the GUID
    [sharedNoteStore getSharedNotebookByAuthWithSuccess:^(EDAMSharedNotebook *sharedNotebook) {
        EDAMNoteFilter* noteFilter = [[EDAMNoteFilter alloc] initWithOrder:filter.order
                                                                 ascending:filter.ascending
                                                                     words:filter.words
                                                              notebookGuid:sharedNotebook.notebookGuid
                                                                  tagGuids:filter.tagGuids
                                                                  timeZone:filter.timeZone
                                                                  inactive:filter.inactive
                                                                emphasized:filter.emphasized];
        [sharedNoteStore findNotesWithFilter:noteFilter
                                      offset:0
                                    maxNotes:200
                                     success:^(EDAMNoteList *list) {
                                         success(list);
                                         
                                     } failure:^(NSError *error) {
                                         failure(error);
                                     }];;
    } failure:^(NSError *error) {
        failure(error);
    }];

}

#pragma mark - Evernote Business Notebooks

- (void)listBusinessNotebooksWithSuccess:(void(^)(NSArray *linkedNotebooks))success
                               failure:(void(^)(NSError *error))failure {
    [self listLinkedNotebooksWithSuccess:^(NSArray *linkedNotebooks) {
        NSMutableArray *businessNotebooksMutable = [NSMutableArray array];
        for (EDAMLinkedNotebook* linkedNotebook in linkedNotebooks) {
            if([linkedNotebook businessIdIsSet]) {
                [businessNotebooksMutable addObject:linkedNotebook];
            }
        }
        NSArray* businessNotebooks = [NSArray arrayWithArray:businessNotebooksMutable];
        success(businessNotebooks);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)isBusinessNotebookWritable:(EDAMLinkedNotebook *)linkedNotebook
                                            success:(void(^)(BOOL isWritable))success
                                      failure:(void(^)(NSError *error))failure {
    [self getCorrespondingNotebookForBusinessNotebook:linkedNotebook success:^(EDAMNotebook *notebook) {
        if(notebook.restrictions.noCreateNotes==YES) {
            success(NO);
        } else {
            success(YES);
        }
    } failure:failure];
}

- (void)createBusinessNotebook:(EDAMNotebook *)notebook
               success:(void(^)(EDAMLinkedNotebook *notebook))success
                       failure:(void(^)(NSError *error))failure {
    EvernoteNoteStore* businessNoteStore = [EvernoteNoteStore businessNoteStore];
    [businessNoteStore createNotebook:notebook success:^(EDAMNotebook *businessNotebook) {
        EDAMSharedNotebook* sharedNotebook = businessNotebook.sharedNotebooks[0];
        EDAMLinkedNotebook* linkedNotebook = [[EDAMLinkedNotebook alloc] init];
        [linkedNotebook setShareKey:[sharedNotebook shareKey]];
        [linkedNotebook setShareName:[businessNotebook name]];
        [linkedNotebook setUsername:[[[EvernoteSession sharedSession] businessUser] username]];
        [linkedNotebook setShardId:[[[EvernoteSession sharedSession] businessUser] shardId]];
        [self createLinkedNotebook:linkedNotebook
                           success:^(EDAMLinkedNotebook *businessLinkedNotebook) {
                               success(businessLinkedNotebook);
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)deleteBusinessNotebook:(EDAMLinkedNotebook *)notebook
                       success:(void(^)(int32_t usn))success
                       failure:(void(^)(NSError *error))failure {
    EvernoteNoteStore* businessNoteStore = [EvernoteNoteStore businessNoteStore];
    EvernoteNoteStore* sharedNoteStore = [EvernoteNoteStore noteStoreForLinkedNotebook:notebook];
    [sharedNoteStore getSharedNotebookByAuthWithSuccess:^(EDAMSharedNotebook *sharedNotebook) {
        NSMutableArray* notebookIds = [NSMutableArray arrayWithArray:@[[NSNumber numberWithLongLong:sharedNotebook.id]]];
        [businessNoteStore expungeSharedNotebooksWithIds:notebookIds success:^(int32_t usn) {
            [self expungeLinkedNotebookWithGuid:notebook.guid success:^(int32_t expungedUsn) {
                success(expungedUsn);
            } failure:failure];
        } failure:failure];
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getCorrespondingNotebookForBusinessNotebook:(EDAMLinkedNotebook *)notebook
                         success:(void(^)(EDAMNotebook *notebook))success
                         failure:(void(^)(NSError *error))failure {
    EvernoteNoteStore* sharedNoteStore = [EvernoteNoteStore noteStoreForLinkedNotebook:notebook];
    [sharedNoteStore getSharedNotebookByAuthWithSuccess:^(EDAMSharedNotebook *sharedNotebook) {
        EvernoteNoteStore* businessNoteStore = [EvernoteNoteStore businessNoteStore];
        [businessNoteStore getNotebookWithGuid:sharedNotebook.notebookGuid success:^(EDAMNotebook *correspondingNotebook) {
            success(correspondingNotebook);
        } failure:failure];
    } failure:failure];
}

#pragma mark - Evernote Business Notes

- (void)createNote:(EDAMNote *)note
        inBusinessNotebook:(EDAMLinkedNotebook*) notebook
                   success:(void(^)(EDAMNote *note))success
                   failure:(void(^)(NSError *error))failure {
    EvernoteNoteStore* sharedNoteStore = [EvernoteNoteStore noteStoreForLinkedNotebook:notebook];
    [sharedNoteStore getSharedNotebookByAuthWithSuccess:^(EDAMSharedNotebook *sharedNotebook) {
        [note setNotebookGuid:sharedNotebook.notebookGuid];
        [sharedNoteStore createNote:note success:^(EDAMNote *createdNote) {
            success(createdNote);
        } failure:failure];
    } failure:failure];
}

#pragma mark - Evernote Business Tags

- (void)createBusinessTag:(EDAMTag *)tag
          success:(void(^)(EDAMTag *tag))success
          failure:(void(^)(NSError *error))failure {
    EvernoteNoteStore* businessNoteStore = [EvernoteNoteStore businessNoteStore];
    [businessNoteStore
     createTag:tag
     success:success
     failure:failure];
}

#pragma mark - Application bridge 

- (void)saveNewNoteToEvernoteApp:(EDAMNote*)note withType:(NSString*)contentMimeType {
    if([[EvernoteSession sharedSession] isEvernoteInstalled]) {
        NSMutableDictionary* appBridgeData = [NSMutableDictionary dictionary];
        ENNewNoteRequest* request = [[ENNewNoteRequest alloc] init];
        NSMutableArray *enResources = [NSMutableArray array];
        [request setTitle:note.title];
        [request setContent:note.content];
        [request setContentMimeType:contentMimeType];
        [request setTagNames:note.tagNames];
        [request setLatitude:[note.attributes latitude]];
        [request setLongitude:[note.attributes longitude]];
        [request setAltitude:[note.attributes altitude]];
        if(note.resources.count > 0) {
            for (EDAMResource *edamResource in note.resources) {
                ENResourceAttachment *enRes = [[ENResourceAttachment alloc] init];
                [enRes setMimeType:edamResource.mime];
                [enRes setFilename:edamResource.attributes.fileName];
                [enRes setResourceData:edamResource.data.body];
                [enResources addObject:enRes];
            }
            [request setResourceAttachments:[NSArray arrayWithArray:enResources]];
        }
        [request setSourceApplication:[note.attributes sourceApplication]];
        [request setSourceURL:[NSURL URLWithString:[note.attributes sourceURL]]];
        [request setConsumerKey:[[EvernoteSession sharedSession] consumerKey]];
        [appBridgeData setObject:[NSNumber numberWithUnsignedInt:kEN_ApplicationBridge_DataVersion] forKey:kEN_ApplicationBridge_DataVersionKey];
        [appBridgeData setObject:[request requestIdentifier] forKey:kEN_ApplicationBridge_RequestIdentifierKey];
        [appBridgeData setObject:[[EvernoteSession sharedSession] consumerKey] forKey:kEN_ApplicationBridge_ConsumerKey];
        
        
        NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
        [appBridgeData setObject:requestData forKey:kEN_ApplicationBridge_RequestDataKey];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        if (infoDictionary != nil) {
            NSString *appIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
            if (appIdentifier != nil) {
                [appBridgeData setObject:appIdentifier forKey:kEN_ApplicationBridge_CallerAppIdentifierKey];
            }
            NSString *appName = [infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
            if (appName != nil) {
                [appBridgeData setObject:appName forKey:kEN_ApplicationBridge_CallerAppNameKey];
            }
        }
        NSString* pasteboardName = [NSString stringWithFormat:@"com.evernote.bridge.%@",[[EvernoteSession sharedSession] consumerKey]];
        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
        [pasteboard setPersistent:YES];
        [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:appBridgeData] forPasteboardType:@"$EvernoteApplicationBridgeData$"];
        NSString* openURL = [NSString stringWithFormat:@"en://app-bridge/consumerKey/%@/pasteBoardName/%@",[[EvernoteSession sharedSession] consumerKey],pasteboardName];
        BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openURL]];
        if(success) {
            
        }
    }
    else {
        if([[[EvernoteSession sharedSession] delegate] respondsToSelector:@selector(evernoteAppNotInstalled)]) {
            [[[EvernoteSession sharedSession] delegate] evernoteAppNotInstalled];
        }
    }
}

- (void)viewNoteInEvernote:(EDAMNote*)note {
    if([[EvernoteSession sharedSession] isEvernoteInstalled]) {
        NSMutableDictionary* appBridgeData = [NSMutableDictionary dictionary];
        ENNoteViewRequest* request = [[ENNoteViewRequest alloc] init];
        [request setConsumerKey:[[EvernoteSession sharedSession] consumerKey]];
        [request setNoteID:note.guid];
        [[EvernoteUserStore userStore] getUserWithSuccess:^(EDAMUser *user) {
            [request setUserID:user.id];
            [request setShardID:user.shardId];
            NSData *requestData = [NSKeyedArchiver archivedDataWithRootObject:request];
            [appBridgeData setObject:requestData forKey:kEN_ApplicationBridge_RequestDataKey];
            
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            if (infoDictionary != nil) {
                NSString *appIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
                if (appIdentifier != nil) {
                    [appBridgeData setObject:appIdentifier forKey:kEN_ApplicationBridge_CallerAppIdentifierKey];
                }
                NSString *appName = [infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
                if (appName != nil) {
                    [appBridgeData setObject:appName forKey:kEN_ApplicationBridge_CallerAppNameKey];
                }
            }
            [appBridgeData setObject:[NSNumber numberWithUnsignedInt:kEN_ApplicationBridge_DataVersion] forKey:kEN_ApplicationBridge_DataVersionKey];
            [appBridgeData setObject:[request requestIdentifier] forKey:kEN_ApplicationBridge_RequestIdentifierKey];
            [appBridgeData setObject:[[EvernoteSession sharedSession] consumerKey] forKey:kEN_ApplicationBridge_ConsumerKey];
            NSString* pasteboardName = [NSString stringWithFormat:@"com.evernote.bridge.%@",[[EvernoteSession sharedSession] consumerKey]];
            UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:pasteboardName create:YES];
            [pasteboard setPersistent:YES];
            [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:appBridgeData] forPasteboardType:@"$EvernoteApplicationBridgeData$"];
            NSString* openURL = [NSString stringWithFormat:@"en://app-bridge/consumerKey/%@/pasteBoardName/%@",[[EvernoteSession sharedSession] consumerKey],pasteboardName];
            BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openURL]];
            if(success) {
                
            }

        } failure:^(NSError *error) {
            ;
        }];
           }
    else {
        if([[[EvernoteSession sharedSession] delegate] respondsToSelector:@selector(evernoteAppNotInstalled)]) {
            [[[EvernoteSession sharedSession] delegate] evernoteAppNotInstalled];
        }
    }
}


#pragma mark - Custom extra function

- (void)cancel {
    [[self currentNoteStore] cancel];
}

- (void)setUploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block {
    [[self currentNoteStore] setUploadProgressBlock:block];
}

- (void)setDownloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))block {
    [[self currentNoteStore] setDownloadProgressBlock:block];
}

@end
