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
#import "EDAMTypes.h"

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
        EDAMNoteFilter* noteFilter = [[[EDAMNoteFilter alloc] initWithOrder:filter.order
                                                                 ascending:filter.ascending
                                                                     words:filter.words
                                                              notebookGuid:sharedNotebook.notebookGuid
                                                                  tagGuids:filter.tagGuids
                                                                  timeZone:filter.timeZone
                                                                  inactive:filter.inactive
                                                                emphasized:filter.emphasized] autorelease];
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

- (void)createBusinessNotebook:(EDAMNotebook *)notebook
               success:(void(^)(EDAMLinkedNotebook *notebook))success
                       failure:(void(^)(NSError *error))failure {
    EvernoteNoteStore* businessNoteStore = [EvernoteNoteStore businessNoteStore];
    [businessNoteStore createNotebook:notebook success:^(EDAMNotebook *notebook) {
        EDAMSharedNotebook* sharedNotebook = notebook.sharedNotebooks[0];
        EDAMLinkedNotebook* linkedNotebook = [[[EDAMLinkedNotebook alloc] init] autorelease];
        [linkedNotebook setShareKey:[sharedNotebook shareKey]];
        [linkedNotebook setShareName:[notebook name]];
        [linkedNotebook setUsername:[[[EvernoteSession sharedSession] businessUser] username]];
        [linkedNotebook setShardId:[[[EvernoteSession sharedSession] businessUser] shardId]];
        [self createLinkedNotebook:linkedNotebook
                           success:^(EDAMLinkedNotebook *linkedNotebook) {
                               success(linkedNotebook);
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
        [businessNoteStore expungeSharedNotebooksWithIds:@[[NSNumber numberWithInt:sharedNotebook.id]] success:^(int32_t usn) {
            [self expungeLinkedNotebookWithGuid:notebook.guid success:^(int32_t usn) {
                success(usn);
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
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - Evernote Business Notes

- (void)createBusinessNote:(EDAMNote *)note
                   success:(void(^)(EDAMNote *note))success
                   failure:(void(^)(NSError *error))failure {
    EvernoteNoteStore* businessNoteStore = [EvernoteNoteStore businessNoteStore];
    [businessNoteStore createNote:note
                          success:success
                          failure:failure];
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

@end
