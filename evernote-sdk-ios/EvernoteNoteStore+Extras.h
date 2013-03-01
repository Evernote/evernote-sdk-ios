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

/** Some utility functions for the Evernote NoteStore, which makes it easier to use Business API's and Shared Note API's.
 */
@interface EvernoteNoteStore (Extras)

#pragma mark - Shared notes
///---------------------------------------------------------------------------------------
/// @name NoteStore convenience methods for shared notes
///---------------------------------------------------------------------------------------

/** Asks the NoteStore to all the notes in the given linked notebook.
 
 This is a utility function that makes it easier to access notes in the linked notebooks. Internally, it does the authentication(to the linked notebook) for you.
 
 @param linkedNotebook The linked notebook, this can be retrieved using listLinkedNotebooksWithSuccess:failure: or createLinkedNotebook:success:failure:
 @param filter The filter to be used
 @param success Success completion block.
 @param failure Failure completion block.
*/
- (void)listNotesForLinkedNotebook:(EDAMLinkedNotebook*)linkedNotebook
                              withFilter:(EDAMNoteFilter *)filter
                                 success:(void(^)(EDAMNoteList *list))success
                                 failure:(void(^)(NSError *error))failure;

#pragma mark - Evernote Business Notebooks

///---------------------------------------------------------------------------------------
/// @name NoteStore convenience methods for Evernote Business
///---------------------------------------------------------------------------------------

/** List all the business notebooks in a users account.
 
 This is a utility function that makes it easier to access all the business notebooks. Internally, it does the authentication to Business for you.
 
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)listBusinessNotebooksWithSuccess:(void(^)(NSArray *linkedNotebooks))success
                                 failure:(void(^)(NSError *error))failure;

/** Check if the business notebook is writable.
 
 This is a utility function that makes it easier to find if a business notebook is writable for this user.
 
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)isBusinessNotebookWritable:(EDAMLinkedNotebook *)linkedNotebook
                           success:(void(^)(BOOL isWritable))success
                           failure:(void(^)(NSError *error))failure;

/** Create a new business notebook.
 
 This is a utility function that makes it easier to create a new Business notebook. Internally, it does the authentication to Business for you.
 
 @param notebook Details on the business notebook to be created.
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)createBusinessNotebook:(EDAMNotebook *)notebook
                       success:(void(^)(EDAMLinkedNotebook *notebook))success
                       failure:(void(^)(NSError *error))failure;

/** Remove a business notebook from a users account.
 
 This is a utility function that makes it easier to create a new Business notebook. Internally, it does the authentication to Business for you.
 
 @param notebook Details on the business notebook to be removed.
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)deleteBusinessNotebook:(EDAMLinkedNotebook *)notebook
                        success:(void(^)(int32_t usn))success
                        failure:(void(^)(NSError *error))failure;

/** Get the corresponding Notebook, given a Linked Notebook
 
 @param notebook Details on the linked notebook, for which you need a notebook.
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)getCorrespondingNotebookForBusinessNotebook:(EDAMLinkedNotebook *)notebook
                                            success:(void(^)(EDAMNotebook *notebook))success
                                            failure:(void(^)(NSError *error))failure;

#pragma mark - Evernote Business Notes
/** Create a new business note (has be in an existing business notebook)
 
 @param note Details on the business note to be created.
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)createBusinessNote:(EDAMNote *)note
           success:(void(^)(EDAMNote *note))success
           failure:(void(^)(NSError *error))failure;

#pragma mark - Evernote Business Tags

/** Create a new business tag 
 
 @param tag Details on the business tag to be created.
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)createBusinessTag:(EDAMTag *)tag
                  success:(void(^)(EDAMTag *tag))success
                  failure:(void(^)(NSError *error))failure;

/** Save a new note to the Evernote for iOS app
 
 After completetion the ENSessionDelegate will be used to confirm success or failure.
 
 @param note The note that needs to be saved.
 @param contentMimeType This can be either text/plain or text/html.
 */
- (void)saveNewNoteToEvernoteApp:(EDAMNote*)note withType:(NSString*)contentMimeType;

/** View a note using the Evernote for iOS app
 
 After completetion the ENSessionDelegate will be used to confirm success or failure.
 
 @param note The note that needs to be viewed.
 */
- (void)viewNoteInEvernote:(EDAMNote*)note;

/** Cancel the first operation in the queue
 */
- (void) cancel;

@end
