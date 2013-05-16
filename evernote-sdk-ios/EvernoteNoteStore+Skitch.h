/*
 * EvernoteNoteStore+Skitch.h
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

@interface EvernoteNoteStore (Skitch)

/** Skitch an image using the Skitch for iOS app
 
 After completetion the ENSessionDelegate will be used to confirm success or failure.
 
 @param filePath The file path of the image.
 */
- (void)skitchImage:(NSString*)filePath;


/** Skitch an image using the Skitch for iOS app
 
 After completetion the ENSessionDelegate will be used to confirm success or failure.
 
 @param fileData Binary data of the resource.
 @param mimeType mime type of the resource
 */
- (void)skitchWithData:(NSData*)fileData withMimeType:(NSString*)mimeType;

/** View a skitch using the Skitch for iOS app
 
 @param guid GUID of the skitch(note).
 */
- (void)viewSkitchWithGUID:(NSString*)guid;

@end
