/*
 * EvernoteSession.m
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

#import <UIKit/UIKit.h>
#import "ENCredentials.h"
#import "ENCredentialStore.h"
#import "EvernoteSDK.h"
#import "EvernoteSession.h"
#import "GCOAuth.h"
#import "NSString+URLEncoding.h"
#import "Thrift.h"

#define SCHEME @"https"

@interface EvernoteSession()

@property (nonatomic, retain) UIViewController *viewController;

@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSMutableData *receivedData;

@property (nonatomic, retain) ENCredentialStore *credentialStore;

@property (nonatomic, copy) EvernoteAuthCompletionHandler completionHandler;
@property (nonatomic, retain) NSString *tokenSecret;

// generate a dictionary of name=>value from the given queryString
+ (NSDictionary *)parametersFromQueryString:(NSString *)queryString;

// generate properly escaped string for the given parameters
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;

- (NSString *)callbackScheme;
- (NSString *)oauthCallback;
- (ENCredentials *)credentials;

- (void)completeAuthenticationWithError:(NSError *)error;

@end

@implementation EvernoteSession

@synthesize viewController = _viewController;
@synthesize response = _response;
@synthesize receivedData = _receivedData;

@synthesize credentialStore = _credentialStore;
@synthesize host = _host;
@synthesize consumerKey = _consumerKey;
@synthesize consumerSecret = _consumerSecret;
@synthesize tokenSecret = _tokenSecret;

@synthesize completionHandler = _completionHandler;
@synthesize queue = _queue;

@dynamic authenticationToken;
@dynamic isAuthenticated;
@dynamic userStoreUrl;
@dynamic noteStoreUrl;
@dynamic webApiUrlPrefix;

- (void)dealloc
{
    [_viewController release];
    [_consumerKey release];
    [_consumerSecret release];
    [_credentialStore release];
    [_host release];
    [_receivedData release];
    [_response release];
    [_tokenSecret release];
    dispatch_release(_queue);
    [super dealloc];
}

- (id)init 
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithHost:(NSString *)host 
       consumerKey:(NSString *)consumerKey 
    consumerSecret:(NSString *)consumerSecret 
{
    self = [super init];
    if (self) {
        self.host = host;
        self.consumerKey = consumerKey;
        self.consumerSecret = consumerSecret;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.credentialStore = [ENCredentialStore load];
    if (!self.credentialStore) {
        self.credentialStore = [[[ENCredentialStore alloc] init] autorelease];
        [self.credentialStore save];
    } 
    _queue = dispatch_queue_create("com.evernote.sdk.EvernoteSession", NULL);
}

+ (void)setSharedSessionHost:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret 
{
    EvernoteSession *session = [self sharedSession];
    session.host = host;
    session.consumerKey = consumerKey;
    session.consumerSecret = consumerSecret;
}

+ (EvernoteSession *)sharedSession
{
    static EvernoteSession *sharedSession;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedSession = [[self alloc] init];
    });
    return sharedSession;
}

- (ENCredentials *)credentials
{
    return [self.credentialStore credentialsForHost:self.host];
}

- (NSString *)authenticationToken
{
    return [[self credentials] authenticationToken];
}

- (BOOL)isAuthenticated
{
    return (self.authenticationToken != nil);
}

- (NSString *)userStoreUrl
{
    // If the host string includes an explict port (e.g., foo.bar.com:8080), use http. Otherwise https.
    
    // use a simple regex to check for a colon and port number suffix
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*:[0-9]+"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];        
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.host
                                                        options:0
                                                          range:NSMakeRange(0, [self.host length])];
    BOOL hasPort = (numberOfMatches > 0);
    NSString *scheme = (hasPort) ? @"http" : @"https";    
    return [NSString stringWithFormat:@"%@://%@/edam/user", scheme, self.host];
}

- (NSString *)noteStoreUrl
{
    return [[self credentials] noteStoreUrl];
}

- (NSString *)webApiUrlPrefix
{
    return [[self credentials] webApiUrlPrefix];
}

- (EDAMNoteStoreClient *)noteStore
{
    NSURL *url = [NSURL URLWithString:[self credentials].noteStoreUrl];
    THTTPClient *transport = [[[THTTPClient alloc] initWithURL:url] autorelease];
    TBinaryProtocol *protocol = [[[TBinaryProtocol alloc] initWithTransport:transport] autorelease];
    return [[[EDAMNoteStoreClient alloc] initWithProtocol:protocol] autorelease];
}

- (EDAMUserStoreClient *)userStore
{
    NSURL *url = [NSURL URLWithString:[self userStoreUrl]];
    THTTPClient *transport = [[[THTTPClient alloc] initWithURL:url] autorelease];
    TBinaryProtocol *protocol = [[[TBinaryProtocol alloc] initWithTransport:transport] autorelease];
    return [[[EDAMUserStoreClient alloc] initWithProtocol:protocol] autorelease];
}

- (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request
{
    return [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - Authentication methods

- (void)logout
{
    // remove all credentials from the store and keychain
    [self.credentialStore clearAllCredentials];
    
    // remove the store from user defaults
    [self.credentialStore delete];
}

- (void)authenticateWithViewController:(UIViewController *)viewController
                     completionHandler:(EvernoteAuthCompletionHandler)completionHandler
{
    self.viewController = viewController;
    self.completionHandler = completionHandler;

    // authenticate is idempotent; check if we're already authenticated
    if (self.isAuthenticated) {
        [self completeAuthenticationWithError:nil];
        return;
    }
    
    // Do app setup sanity checks before beginning OAuth process.
    // This verification raises an NSException if problems are found.
    [self verifyConsumerKeyAndSecret];

    if (!viewController) {
        // no point continuing without a valid view controller,
        [self completeAuthenticationWithError:[NSError errorWithDomain:EvernoteSDKErrorDomain 
                                                                  code:EvernoteSDKErrorCode_NO_VIEWCONTROLLER 
                                                              userInfo:nil]];
        return;
    }
        
    // start the OAuth dance to get credentials (auth token, noteStoreUrl, etc).
    [self startOauthAuthentication];    
}

- (void)verifyConsumerKeyAndSecret
{
    // raise an exception if we don't have consumer key and secret set
    if (!self.consumerKey ||
        [self.consumerKey isEqualToString:@""] ||
        [self.consumerKey isEqualToString:@"your key"] ||
        !self.consumerSecret ||
        [self.consumerSecret isEqualToString:@""] ||
        [self.consumerSecret isEqualToString:@"your secret"]) {
        [NSException raise:@"Invalid EvernoteSession" format:@"Please use a valid consumerKey and consumerSecret."];
    }
}

- (void)startOauthAuthentication
{
    // OAuth step 1: temporary credentials (aka request token) request
    NSURLRequest *tempTokenRequest = [GCOAuth URLRequestForPath:@"/oauth"
                                                  GETParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [self oauthCallback], @"oauth_callback", nil]
                                                         scheme:SCHEME
                                                           host:self.host
                                                    consumerKey:self.consumerKey
                                                 consumerSecret:self.consumerSecret
                                                    accessToken:nil
                                                    tokenSecret:nil];    
    NSURLConnection *connection = [self connectionWithRequest:tempTokenRequest];
    if (!connection) {
        // can't make connection, so immediately fail.
        [self completeAuthenticationWithError:[NSError errorWithDomain:EvernoteSDKErrorDomain 
                                                       code:EvernoteSDKErrorCode_TRANSPORT_ERROR 
                                                   userInfo:nil]];
    }
}

- (NSString *)callbackScheme
{
    // The callback scheme is client-app specific, of the form en-CONSUMERKEY
    return [NSString stringWithFormat:@"en-%@", self.consumerKey];
}

- (NSString *)oauthCallback
{
    // The full callback URL is en-CONSUMERKEY://response
    return [NSString stringWithFormat:@"%@://response", [self callbackScheme]];
}

/**
 * Make an authorization URL.
 *
 * E.g.,
 * https://www.evernote.com/OAuth.action?oauth_token=en_oauth_test.12345 
 */
- (NSString *)userAuthorizationURLStringWithParameters:(NSDictionary *)tokenParameters
{
    NSDictionary *authParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [tokenParameters objectForKey:@"oauth_token"], @"oauth_token", 
                                    nil];
    NSString *queryString = [EvernoteSession queryStringFromParameters:authParameters];
    return [NSString stringWithFormat:@"%@://%@/OAuth.action?%@", SCHEME, self.host, queryString];    
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    [self.viewController dismissModalViewControllerAnimated:YES];

    // only handle our specific oauth_callback URLs
    if (![[url absoluteString] hasPrefix:[self oauthCallback]]) {
        return NO;
    }
    
    // OAuth step 3: got authorization from the user, now get a real token.
    NSDictionary *parameters = [EvernoteSession parametersFromQueryString:url.query];
    NSString *oauthToken = [parameters objectForKey:@"oauth_token"];
    NSString *oauthVerifier = [parameters objectForKey:@"oauth_verifier"];
    NSURLRequest *authTokenRequest = [GCOAuth URLRequestForPath:@"/oauth"
                                                  GETParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 oauthVerifier, @"oauth_verifier", nil]
                                                         scheme:SCHEME
                                                           host:self.host
                                                    consumerKey:self.consumerKey
                                                 consumerSecret:self.consumerSecret
                                                    accessToken:oauthToken
                                                    tokenSecret:self.tokenSecret];    
    NSURLConnection *connection = [self connectionWithRequest:authTokenRequest];
    if (!connection) {
        // can't make connection, so immediately fail.
        [self completeAuthenticationWithError:[NSError errorWithDomain:EvernoteSDKErrorDomain 
                                                       code:EvernoteSDKErrorCode_TRANSPORT_ERROR 
                                                   userInfo:nil]];
    }
    
    return YES;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.receivedData = nil;
    self.response = nil;
    [self completeAuthenticationWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = response;
    self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *string = [[[NSString alloc] initWithData:self.receivedData 
                                              encoding:NSUTF8StringEncoding] autorelease];

    // Trap bad HTTP response status codes.
    // This might be from an invalid consumer key, a key not set up for OAuth, etc.
    // Usually this shows up as a 401 response with an error page, so
    // log it and callback an error.
    if ([self.response respondsToSelector:@selector(statusCode)]) {
        int statusCode = [(id)self.response statusCode];
        if (statusCode != 200) {
            NSLog(@"Received error HTTP response code: %d", statusCode);
            NSLog(@"%@", string);
            [self completeAuthenticationWithError:[NSError errorWithDomain:EvernoteSDKErrorDomain 
                                                           code:EvernoteSDKErrorCode_TRANSPORT_ERROR 
                                                       userInfo:nil]];
            self.receivedData = nil;
            self.response = nil;
            return;
        }
    }
    
    NSDictionary *parameters = [EvernoteSession parametersFromQueryString:string];
    
    if ([parameters objectForKey:@"oauth_callback_confirmed"]) {
        // OAuth step 2: got our temp token, now get authorization from the user.
        // Save the token secret, for later use in OAuth step 3.
        self.tokenSecret = [parameters objectForKey:@"oauth_token_secret"];
        
        // Open a modal ENOAuthViewController on top of our given view controller,
        // and point it at the proper Evernote web page so the user can authorize us.
        NSString *userAuthURLString = [self userAuthorizationURLStringWithParameters:parameters];
        NSURL *userAuthURL = [NSURL URLWithString:userAuthURLString];
        [self openOAuthViewControllerWithURL:userAuthURL];
        
    } else {
        // OAuth step 4: final callback, with our real token
        NSString *authenticationToken = [parameters objectForKey:@"oauth_token"];
        NSString *noteStoreUrl = [parameters objectForKey:@"edam_noteStoreUrl"];
        NSString *edamUserId = [parameters objectForKey:@"edam_userId"];
        NSString *webApiUrlPrefix = [parameters objectForKey:@"edam_webApiUrlPrefix"];
        // Evernote doesn't use the token secret, so we can ignore it.
        // NSString *oauthTokenSecret = [parameters objectForKey:@"oauth_token_secret"];
        
        // If any of the fields are nil, we can't continue.
        // Assume an invalid response from the server.
        if (!authenticationToken || !noteStoreUrl || !edamUserId || !webApiUrlPrefix) {
            [self completeAuthenticationWithError:[NSError errorWithDomain:EvernoteSDKErrorDomain 
                                                           code:EDAMErrorCode_INTERNAL_ERROR 
                                                       userInfo:nil]];
        } else {        
            // add auth info to our credential store, saving to user defaults and keychain
            [self saveCredentialsWithEdamUserId:edamUserId 
                                   noteStoreUrl:noteStoreUrl
                                webApiUrlPrefix:webApiUrlPrefix
                            authenticationToken:authenticationToken];
            
            // call our callback, without error.
            [self completeAuthenticationWithError:nil];
        }
    }

    self.receivedData = nil;
    self.response = nil;
}

- (void)openOAuthViewControllerWithURL:(NSURL *)authorizationURL
{
    ENOAuthViewController *oauthViewController = [[[ENOAuthViewController alloc] initWithAuthorizationURL:authorizationURL
                                                   oauthCallbackPrefix:[self oauthCallback]
                                                                                                 delegate:self] autorelease];
    UINavigationController *oauthNavController = [[[UINavigationController alloc] initWithRootViewController:oauthViewController] autorelease];

    // use a formsheet on iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        oauthViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        oauthNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self.viewController presentModalViewController:oauthNavController animated:YES];
}

- (void)saveCredentialsWithEdamUserId:(NSString *)edamUserId 
                         noteStoreUrl:(NSString *)noteStoreUrl
                      webApiUrlPrefix:(NSString *)webApiUrlPrefix
                  authenticationToken:(NSString *)authenticationToken
{
    ENCredentials *ec = [[[ENCredentials alloc] initWithHost:self.host
                                                  edamUserId:edamUserId 
                                                noteStoreUrl:noteStoreUrl 
                                             webApiUrlPrefix:webApiUrlPrefix
                                         authenticationToken:authenticationToken] autorelease];
    [self.credentialStore addCredentials:ec];    
}

- (void)completeAuthenticationWithError:(NSError *)error
{
    if (self.completionHandler) {
        self.completionHandler(error);
    }
    self.completionHandler = nil;
    self.viewController = nil;
}

#pragma mark - querystring parsing

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters 
{
    NSMutableArray *entries = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *entry = [NSString stringWithFormat:@"%@=%@", [key URLEncodedString], [obj URLEncodedString]];
        [entries addObject:entry];
    }];
    return [entries componentsJoinedByString:@"&"];
}

+ (NSDictionary *)parametersFromQueryString:(NSString *)queryString 
{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    NSArray *nameValues = [queryString componentsSeparatedByString:@"&"];
    for (NSString *nameValue in nameValues) {
        NSArray *components = [nameValue componentsSeparatedByString:@"="];
        if ([components count] == 2) {
            NSString *name = [[components objectAtIndex:0] URLDecodedString];
            NSString *value = [[components objectAtIndex:1] URLDecodedString];
            if (name && value) {
                [dict setObject:value forKey:name];
            }
        }
    }
    return dict;
}

#pragma mark - ENOAuthViewControllerDelegate

- (void)oauthViewControllerDidCancel:(ENOAuthViewController *)sender
{
    [self.viewController dismissModalViewControllerAnimated:YES];    
	[self completeAuthenticationWithError:nil];
}

- (void)oauthViewController:(ENOAuthViewController *)sender didFailWithError:(NSError *)error
{
    [self.viewController dismissModalViewControllerAnimated:YES];
    [self completeAuthenticationWithError:error];
}

- (void)oauthViewController:(ENOAuthViewController *)sender receivedOAuthCallbackURL:(NSURL *)url
{
    [self.viewController dismissModalViewControllerAnimated:YES];
    
    // OAuth step 3: got authorization from the user, now get a real token.
    NSDictionary *parameters = [EvernoteSession parametersFromQueryString:url.query];
    NSString *oauthToken = [parameters objectForKey:@"oauth_token"];
    NSString *oauthVerifier = [parameters objectForKey:@"oauth_verifier"];
    NSURLRequest *authTokenRequest = [GCOAuth URLRequestForPath:@"/oauth"
                                                  GETParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 oauthVerifier, @"oauth_verifier", nil]
                                                         scheme:SCHEME
                                                           host:self.host
                                                    consumerKey:self.consumerKey
                                                 consumerSecret:self.consumerSecret
                                                    accessToken:oauthToken
                                                    tokenSecret:self.tokenSecret];    
    NSURLConnection *connection = [self connectionWithRequest:authTokenRequest];
    if (!connection) {
        // can't make connection, so immediately fail.
        [self completeAuthenticationWithError:[NSError errorWithDomain:EvernoteSDKErrorDomain 
                                                       code:EvernoteSDKErrorCode_TRANSPORT_ERROR 
                                                   userInfo:nil]];
    }
}

@end
