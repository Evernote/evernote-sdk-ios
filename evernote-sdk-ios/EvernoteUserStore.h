/*
 * EvernoteUserStore.h
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
#import "ENAPI.h"

/** Asynchronous functions for all the user store api's.
 
 This class is a wrapper over all the User store api's that provides asynchronism and abstraction.
 */
@interface EvernoteUserStore : ENAPI

///---------------------------------------------------------------------------------------
/// @name Creating a NoteStore
///---------------------------------------------------------------------------------------

/** Get an instance, using the shared EvernoteSession. */
+ (instancetype)userStore;

/** Construct an instance with the given session.
 
 @param session The Evernote session object
 */
- (id)initWithSession:(EvernoteSession *)session;

///---------------------------------------------------------------------------------------
/// @name UserStore methods
///---------------------------------------------------------------------------------------

/** This should be the first call made by a client to the EDAM service. It tells the service what protocol version is used by the client. 
 
 The service will then return true if the client is capable of talking to the service, and false if the client's protocol version is incompatible with the service, so the client must upgrade. If a client receives a false value, it should report the incompatibility to the user and not continue with any more EDAM requests (UserStore or NoteStore).

 @param  clientName This string provides some information about the client for tracking/logging on the service. It should provide information about the client's software and platform. The structure should be: application/version; platform/version; [ device/version ] E.g. "Evernote Windows/3.0.1; Windows/XP SP3" or "Evernote Clipper/1.0.1; JME/2.0; Motorola RAZR/2.0;
 
 @param  edamVersionMajor This should be the major protocol version that was compiled by the client. This should be the current value of the EDAM_VERSION_MAJOR constant for the client.
 @param  edamVersionMinor This should be the major protocol version that was compiled by the client. This should be the current value of the EDAM_VERSION_MINOR constant for the client.
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)checkVersionWithClientName:(NSString *)clientName 
                  edamVersionMajor:(int16_t)edamVersionMajor 
                  edamVersionMinor:(int16_t)edamVersionMinor
                           success:(void(^)(BOOL versionOK))success
                           failure:(void(^)(NSError *error))failure;

/** This provides bootstrap information to the client. 
 
 Various bootstrap profiles and settings may be used by the client to configure itself.
 
 @param  locale The client's current locale, expressed in language[_country] format. E.g., "en_US". See ISO-639 and ISO-3166 for valid language and country codes.
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)getBootstrapInfoWithLocale:(NSString *)locale
                           success:(void(^)(EDAMBootstrapInfo *info))success
                           failure:(void(^)(NSError *error))failure;

/** Returns the User corresponding to the provided authentication token, or throws an exception if this token is not valid. 
 
 The level of detail provided in the returned User structure depends on the access level granted by the token, so a web service client may receive fewer fields than an integrated desktop client.
 
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)getUserWithSuccess:(void(^)(EDAMUser *user))success
                   failure:(void(^)(NSError *error))failure;

/** Asks the UserStore about the publicly available location information for a particular username.
 
 @param username The username for the location information
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)getPublicUserInfoWithUsername:(NSString *)username
                              success:(void(^)(EDAMPublicUserInfo *info))success
                              failure:(void(^)(NSError *error))failure;

/** Returns information regarding a user's Premium account corresponding to the provided authentication token, or throws an exception if this token is not valid. 
 
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)getPremiumInfoWithSuccess:(void(^)(EDAMPremiumInfo *info))success
                          failure:(void(^)(NSError *error))failure;

/** Returns the URL that should be used to talk to the NoteStore for the account represented by the provided authenticationToken. 
 
 This method isn't needed by most clients, who can retrieve the correct NoteStore URL from the AuthenticationResult returned from the authenticate or refreshAuthentication calls. This method is typically only needed to look up the correct URL for a long-lived session token (e.g. for an OAuth web service).
 
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)getNoteStoreUrlWithSuccess:(void(^)(NSString *noteStoreUrl))success
                           failure:(void(^)(NSError *error))failure;

/** This is used to take an existing authentication token that grants access to an individual user account (returned from 'authenticate', 'authenticateLongSession' or an OAuth authorization) and obtain an additional authentication token that may be used to access business notebooks if the user is a member of an Evernote Business account.
 
 The resulting authentication token may be used to make NoteStore API calls against the business using the NoteStore URL returned in the result.
 
 @param success Success completion block.
 @param failure Failure completion block.
 */
- (void)authenticateToBusinessWithSuccess:(void(^)(EDAMAuthenticationResult *authenticationResult))success
                           failure:(void(^)(NSError *error))failure;

@end
