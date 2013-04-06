/*
 * EvernoteSession.h
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

#import <StoreKit/StoreKit.h>
#import "EDAM.h"
#import "ENOAuthProtocol.h"

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import "ENOAuthViewController.h"
#else
#import "ENOAuthWindowController.h"
#endif

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif
// For Evernote-related error codes, see EDAMErrors.h

/**
 * Post authentication callback.
 
 @param error The error after authentication. It is nil if the authentication is successfull.
 */
typedef void (^EvernoteAuthCompletionHandler)(NSError *error);

/**
 * Service options.
 */
typedef enum {
    /** No service */
    EVERNOTE_SERVICE_NONE = 0,
    /** Evernote international only */
    EVERNOTE_SERVICE_INTERNATIONAL = 1,
    /** Evernote China only */
    EVERNOTE_SERVICE_YINXIANG = 2,
    /** Evernote international and China services */
    EVERNOTE_SERVICE_BOTH = 3
} EvernoteService;

/*!
 @typedef ENSessionState enum
 
 @abstract Used when authenticating with the Evernote iOS app
 
 @discussion
 */
typedef NS_ENUM(NSInteger, ENSessionState) {
    /*! Evernote session has been created but not logged in */
    ENSessionLoggedOut,
    /*! Authentication is in progress */
    ENSessionAuthenticationInProgress,
    /*! Session has been called back by the Evernote app*/
    ENSessionGotCallback,
    /*! Session has authenticated successfully*/
    ENSessionAuthenticated
};

@protocol ENSessionDelegate <NSObject>
- (void)noteSavedWithNoteGuid:(NSString*)noteGuid;
- (void)evernoteAppInstalled;
- (void)evernoteAppNotInstalled;
@end

/** The `EvernoteSession` class provides a centralized place for authentication and gives access to the `EvernoteNoteStore` and `EvernoteUserStore` objects. Every application must have exactly one instance of `EvernoteSession`. When an application is ready, the application:didFinishLaunchingWithOptions: function is called, where you should call the class method setSharedSessionHost:consumerKey:consumerSecret:supportedService: Thereafter you can access this object by invoking the sharedSession class method.
 */
@interface EvernoteSession : NSObject <ENOAuthDelegate
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
, SKStoreProductViewControllerDelegate
#endif
>

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
/*! The delegate of the Evernote session */
@property (nonatomic, assign) id<ENSessionDelegate> delegate;

///---------------------------------------------------------------------------------------
/// @name Session data
///---------------------------------------------------------------------------------------

/*! The detailed state of the session */
@property(readonly) ENSessionState state;

/** Determines whether this session is authenticated or not. */
@property (nonatomic, readonly) BOOL isAuthenticated;

/** Evernote auth token, to be passed to any NoteStore methods. Will only be non-nil once we've authenticated. */
@property (weak, nonatomic, readonly) NSString *authenticationToken;

/** Evernote auth token for Business, to be passed to any NoteStore methods. Will only be non-nil once we've authenticated. */
@property (weak, nonatomic, readonly) NSString *businessAuthenticationToken;

/** URL for the Evernote UserStore. */
@property (weak, nonatomic, readonly) NSString *userStoreUrl;

/** URL for the Evernote NoteStore for the authenticated user. Will only be non-nil once we've authenticated. */
@property (weak, nonatomic, readonly) NSString *noteStoreUrl;

/** URL prefix for the web API. Will only be non-nil once we've authenticated. */
@property (weak, nonatomic, readonly) NSString *webApiUrlPrefix;

/** Shared dispatch queue for API operations. */
@property (nonatomic, readonly) dispatch_queue_t queue;

/** All the bootstrap profiles for the user. */
@property (nonatomic, strong) NSArray* profiles;

/** The business user object. */
@property (nonatomic,strong) EDAMUser* businessUser;

///---------------------------------------------------------------------------------------
/// @name Session handling
///---------------------------------------------------------------------------------------

/** Set up the shared session.
 
 This should be called as soon as the application is ready to run.
 
 @param host The server URL. "sandbox.evernote.com" should be used for testing ."www.evernote.com" for production apps.
 @param consumerKey The consumer key. Get your consumer key [here](http://dev.evernote.com/documentation/cloud/).
 @param consumerSecret The consumer secret.
 */
+ (void)setSharedSessionHost:(NSString *)host
                 consumerKey:(NSString *)consumerKey
              consumerSecret:(NSString *)consumerSecret;


/**
 * Get the singleton shared session.
 @return Returns the singleton session object.
 */
+ (EvernoteSession *)sharedSession;

/**
 * Checks whether the given error signifies an expired token.
 
 @param error The error returned by the API. 
 @return Returns whether the token has expired.
 */
+ (BOOL)isTokenExpiredWithError:(NSError*)error;

/** Handle open url from the Evernote app.
 
 This will used during authentication and should be called from the AppDelegate class.
 
 @param url The URL passed from the AppDelegate
 */
- (BOOL)canHandleOpenURL:(NSURL*)url;

/** Application became active as a result of app switching.
 
 This will be used to handle unexpected events due to app switching.
 */
- (void)handleDidBecomeActive;

/** Authenticate, calling the given handler upon completion.
 
 This should be called to kick off the authentication process with Evernote. 
 
 @param viewController The view controller that should be used to present the authentication view
 @param completionHandler This block will be called once the authentication process is completed with sucess or failure.
*/

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (void)authenticateWithViewController:(UIViewController *)viewController
                     completionHandler:(EvernoteAuthCompletionHandler)completionHandler;
#else
- (void)authenticateWithWindow:(NSWindow *)window
             completionHandler:(EvernoteAuthCompletionHandler)completionHandler;
#endif

/** Check if the Evernote app is installed.
 
 Checks if the Evernote for IOS app is installed on the user's device
 */
- (BOOL) isEvernoteInstalled;

/** Logout and clear authentication.
 
 This will clear all the cookies as well.
 */
- (void)logout;

///---------------------------------------------------------------------------------------
/// @name Accessing user and notes data
///---------------------------------------------------------------------------------------

/** Create a new UserStore client for EDAM calls.
 
 This lets you make API calls to get information about the user. This function may throw an NSException. The returned object is NOT thread safe. 
 
 @return Returns the user store client.
 */
- (EDAMUserStoreClient *)userStore;

/** Create a new NoteStore client for EDAM calls.
 
 This lets you make API calls for all the data. This function may throw an NSException. The returned object is NOT thread safe. 
 
 @return Returns the note store client.
 */
- (EDAMNoteStoreClient *)noteStore;

/** Create a new NoteStore client for EDAM calls.
 
 This lets you make API calls for all the data in the user's business account. This also handles authentication to business, as long as the Evernote session is authenticated. This function may throw an NSException. The returned object is NOT thread safe. 
 
 @return Returns the note store client.
 */
- (EDAMNoteStoreClient *)businessNoteStore;

/** Create a new NoteStore client for EDAM calls.
 
 This lets you make API calls for all the data. This function may throw an NSException. The returned object is NOT thread safe.
 
 @param noteStoreURL The URL of the note store.
 @return Returns the note store client.
 */
- (EDAMNoteStoreClient *)noteStoreWithNoteStoreURL:(NSString*)noteStoreURL;

// Abstracted into a method to support unit testing.
- (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request;

// Exposed for unit testing.
- (void)verifyConsumerKeyAndSecret;

// Abstracted into a method to support unit testing.
// - (void)openOAuthViewControllerWithURL:(NSURL *)authorizationURL;

// Abstracted into a method to support unit testing.
- (void)saveCredentialsWithEdamUserId:(NSString *)edamUserId 
                         noteStoreUrl:(NSString *)noteStoreUrl
                      webApiUrlPrefix:(NSString *)webApiUrlPrefix
                  authenticationToken:(NSString *)authenticationToken;

/** Change the bootstrap profile. 
 
 This is only used by the Authentication flow and should not be called the the application.
 
 @param aProfileName The name of the profile to be switched to.
*/
- (void)updateCurrentBootstrapProfileWithName:(NSString *)aProfileName;

/** Install the evernote for iOS app.
 
 This can be used to present the user with a dialog to install the Evernote for iOS app
 
 @param viewController The view controller that should be used as a base controller to present this view controller.
 */

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (void)installEvernoteAppUsingViewController:(UIViewController*)viewController;
#endif

@end
