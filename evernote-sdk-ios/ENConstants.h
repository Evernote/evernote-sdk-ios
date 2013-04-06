/*
 * ENConstants.h
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


#import <Foundation/Foundation.h>

@interface ENConstants : NSObject

FOUNDATION_EXPORT NSString * const ENBootstrapProfileNameChina;
FOUNDATION_EXPORT NSString * const ENBootstrapProfileNameInternational;

FOUNDATION_EXPORT NSString * const BootstrapServerBaseURLStringCN;
FOUNDATION_EXPORT NSString * const BootstrapServerBaseURLStringUS;

FOUNDATION_EXPORT NSString * const kBootstrapServerBaseURLStringUS;
FOUNDATION_EXPORT NSString * const kBootstrapServerBaseURLStringCN;
FOUNDATION_EXPORT NSString * const BootstrapServerBaseURLStringSandbox;

FOUNDATION_EXPORT NSString * const BusinessHostNameSuffix;

FOUNDATION_EXPORT NSString * const ENMLTagCrypt;
FOUNDATION_EXPORT NSString * const ENMLTagTodo;
FOUNDATION_EXPORT NSString * const ENMLTagNote;
FOUNDATION_EXPORT NSString * const ENHTMLClassInkSlice;
FOUNDATION_EXPORT NSString * const ENHTMLClassInkContainer;
FOUNDATION_EXPORT NSString * const ENHTMLClassIgnore;
FOUNDATION_EXPORT NSString * const ENHTMLClassAttachment;

FOUNDATION_EXPORT NSString * const ENHTMLAttributeMime;

FOUNDATION_EXPORT NSString * const ENHTMLEncryptionAttributeHint;
FOUNDATION_EXPORT NSString * const ENHTMLEncryptionAttributeCipher;

FOUNDATION_EXPORT NSString * const ENMIMETypeOctetStream;
FOUNDATION_EXPORT NSString * const ENMLTagMedia;

@end
