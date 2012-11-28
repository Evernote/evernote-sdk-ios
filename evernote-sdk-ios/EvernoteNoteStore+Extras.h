/*
 * EvernoteNoteStore+Extras.h
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

@interface EvernoteNoteStore (Extras)

#pragma mark - Shared notes

- (void)listNotesForLinkedNotebook:(EDAMLinkedNotebook*)linkedNotebook
                              withFilter:(EDAMNoteFilter *)filter
                                 success:(void(^)(EDAMNoteList *list))success
                                 failure:(void(^)(NSError *error))failure;

#pragma mark - Evernote Business Notebooks

// List all the business notebooks in a users account
- (void)listBusinessNotebooksWithSuccess:(void(^)(NSArray *linkedNotebooks))success
                                 failure:(void(^)(NSError *error))failure;

// Create a new business notebook
- (void)createBusinessNotebook:(EDAMNotebook *)notebook
                       success:(void(^)(EDAMLinkedNotebook *notebook))success
                       failure:(void(^)(NSError *error))failure;

// Remove a business notebook from a users account
- (void)deleteBusinessNotebook:(EDAMLinkedNotebook *)notebook
                        success:(void(^)(int32_t usn))success
                        failure:(void(^)(NSError *error))failure;

// Get the corresponding Notebook, given a Linked Notebook
- (void)getCorrespondingNotebookForBusinessNotebook:(EDAMLinkedNotebook *)notebook
                                            success:(void(^)(EDAMNotebook *notebook))success
                                            failure:(void(^)(NSError *error))failure;

#pragma mark - Evernote Business Notes

// Create a new business note (has be in an existing business notebook)
- (void)createBusinessNote:(EDAMNote *)note
           success:(void(^)(EDAMNote *note))success
           failure:(void(^)(NSError *error))failure;

#pragma mark - Evernote Business Tags

// Create a tag 
- (void)createBusinessTag:(EDAMTag *)tag
                  success:(void(^)(EDAMTag *tag))success
                  failure:(void(^)(NSError *error))failure;

@end
