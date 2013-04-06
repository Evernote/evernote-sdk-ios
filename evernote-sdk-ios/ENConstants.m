/*
 * ENConstants.m
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

#import "ENConstants.h"

@implementation ENConstants

NSString * const ENBootstrapProfileNameChina = @"Evernote-China";
NSString * const ENBootstrapProfileNameInternational = @"Evernote";

NSString * const BootstrapServerBaseURLStringCN  = @"app.yinxiang.com";
NSString * const BootstrapServerBaseURLStringUS  = @"www.evernote.com";
NSString * const BootstrapServerBaseURLStringSandbox  = @"sandbox.evernote.com";

NSString * const kBootstrapServerBaseURLStringUS = @"en_US";
NSString * const kBootstrapServerBaseURLStringCN = @"zh";

NSString * const BusinessHostNameSuffix = @"-business";

NSString * const ENMLTagCrypt = @"en-crypt";
NSString * const ENMLTagTodo = @"en-todo";
NSString * const ENMLTagNote = @"en-note";
NSString * const ENHTMLClassInkSlice = @"en-ink-slice";
NSString * const ENHTMLClassInkContainer = @"en-ink-media";

NSString * const ENHTMLClassIgnore = @"en-ignore";
NSString * const ENHTMLClassAttachment = @"en-attachment";

NSString * const ENHTMLAttributeMime = @"x-evernote-mime";

NSString * const ENHTMLEncryptionAttributeHint = @"title";
NSString * const ENHTMLEncryptionAttributeCipher = @"alt";

NSString * const ENMIMETypeOctetStream = @"application/octet-stream";
NSString * const ENMLTagMedia = @"en-media";

@end
