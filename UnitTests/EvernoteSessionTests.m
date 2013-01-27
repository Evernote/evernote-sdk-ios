//
//  EvernoteSessionTests.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 5/1/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EvernoteSDK.h"
#import "EvernoteSession.h"
#import "EvernoteSessionTests.h"
#import <OCMock/OCMock.h>

@interface EvernoteSessionTests() {
    __block BOOL authenticationCompleted;
    __block NSError *authenticationError;
}

@property (nonatomic, retain) id mockSession;
@property (nonatomic, retain) id mockViewController;
@property (nonatomic, retain) NSURLConnection *dummyURLConnection;

@end

@implementation EvernoteSessionTests

@synthesize mockSession = _mockSession;
@synthesize mockViewController = _mockViewController;
@synthesize dummyURLConnection = _dummyURLConnection;

- (void)dealloc
{
    [_mockSession release];
    [_mockViewController release];
    [_dummyURLConnection release];
    [super dealloc];
}

- (void)setUp
{
    [super setUp];

    authenticationCompleted = NO;
    authenticationError = nil;

    EvernoteSession *session = [[[EvernoteSession alloc] init] autorelease];
    session.host = @"unittest.evernote.com";
    session.consumerKey = @"dummyaccount-1234";
    session.consumerSecret = @"123456789";

    self.mockSession = [OCMockObject partialMockForObject:session];

    // mock out our verification methods, since we don't care
    [[self.mockSession stub] verifyConsumerKeyAndSecret];
    
    self.mockViewController = [OCMockObject mockForClass:[UIViewController class]];
    
    // mock out our connection-making method to return a dummy
    self.dummyURLConnection = [[[NSURLConnection alloc] 
                                initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"file:foo"]] 
                                delegate:nil startImmediately:NO] autorelease];    
}

- (void)tearDown
{
    // Tear-down code here.
}

// Make sure our field verification methods throw exceptions as expected.
- (void)testAuthenticationVerifyMethods
{
    EvernoteSession *session = [[[EvernoteSession alloc] init] autorelease];

    // make sure not setting consumer key, secret throws an exception
    @try {
        [session authenticateWithViewController:nil completionHandler:^(NSError *error) {}];
        STFail(@"Should have thrown NSException");
    }
    @catch (NSException *expected) {
        STAssertEqualObjects(expected.description, @"Please use a valid consumerKey and consumerSecret.", nil);
    }
    
    // set required session fields, but make sure we still throw for not setting up info.plist
    session.host = @"foo";
    session.consumerKey = @"dummyaccount-1234";
    session.consumerSecret = @"123456789";
    [session authenticateWithViewController:nil completionHandler:^(NSError *error) {}];
}

// Make sure a nil UIViewController causes a proper error callback.
- (void)testNilViewController
{
    [self.mockSession authenticateWithViewController:nil completionHandler:^(NSError *error) {
        authenticationCompleted = YES;
        authenticationError = error;
    }];

    STAssertTrue(authenticationCompleted, nil);
    STAssertNotNil(authenticationError, nil);
    STAssertEqualObjects(authenticationError.domain, EvernoteSDKErrorDomain, nil);
    STAssertEquals(authenticationError.code, EvernoteSDKErrorCode_NO_VIEWCONTROLLER, nil);
}

// Make sure a nil NSURLConnection causes a proper error callback.
- (void)testNilConnection
{
    [[[self.mockSession stub] andReturn:nil] connectionWithRequest:[OCMArg any]];
    
    [self.mockSession authenticateWithViewController:self.mockViewController completionHandler:^(NSError *error) {
        authenticationCompleted = YES;
        authenticationError = error;
    }];
    
    STAssertTrue(authenticationCompleted, nil);
    STAssertNotNil(authenticationError, nil);
    STAssertEqualObjects(authenticationError.domain, EvernoteSDKErrorDomain, nil);
    STAssertEquals(authenticationError.code, EvernoteSDKErrorCode_TRANSPORT_ERROR, nil);
}

// Make sure connection:didFailWithError causes a proper error callback.
- (void)testURLConnectionDidFailWithError
{    
    [[[self.mockSession stub] andReturn:self.dummyURLConnection] connectionWithRequest:[OCMArg any]];

    [self.mockSession authenticateWithViewController:self.mockViewController completionHandler:^(NSError *error) {
        authenticationCompleted = YES;
        authenticationError = error;
    }];

    NSError *dummyError = [NSError errorWithDomain:@"dummyDomain" code:123 userInfo:nil];
    [self.mockSession connection:self.dummyURLConnection didFailWithError:dummyError];
    STAssertTrue(authenticationCompleted, nil);
    STAssertEqualObjects(authenticationError, dummyError, nil);
}

// Make sure a non-OK HTTP response code causes a proper error callback.
- (void)testURLConnectionNon200
{
    [[[self.mockSession stub] andReturn:self.dummyURLConnection] connectionWithRequest:[OCMArg any]];

    [self.mockSession authenticateWithViewController:self.mockViewController completionHandler:^(NSError *error) {
        authenticationCompleted = YES;
        authenticationError = error;
    }];

    int statusCode = 401;
    id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];    
    [self.mockSession connection:self.dummyURLConnection didReceiveResponse:responseMock];
    STAssertFalse(authenticationCompleted, nil);
    STAssertNil(authenticationError, nil);

    NSString *responseString = @"<html><body>oauth error boohoo</body></html>";
    NSData *responseData = [responseString dataUsingEncoding:NSASCIIStringEncoding];
    [self.mockSession connection:self.dummyURLConnection didReceiveData:responseData];
    STAssertFalse(authenticationCompleted, nil);
    STAssertNil(authenticationError, nil);
    
    [self.mockSession connectionDidFinishLoading:self.dummyURLConnection];    
    STAssertTrue(authenticationCompleted, nil);
    STAssertNotNil(authenticationError, nil);
    STAssertEqualObjects(authenticationError.domain, EvernoteSDKErrorDomain, nil);
    STAssertEquals(authenticationError.code, EvernoteSDKErrorCode_TRANSPORT_ERROR, nil);
}

// Make sure a bad initial temp token response causes a proper error callback.
- (void)testBadTempTokenResponse
{
    [[[self.mockSession stub] andReturn:self.dummyURLConnection] connectionWithRequest:[OCMArg any]];

    [self.mockSession authenticateWithViewController:self.mockViewController completionHandler:^(NSError *error) {
        authenticationCompleted = YES;
        authenticationError = error;
    }];

    // HTTP OK response
    int statusCode = 200;
    id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];    
    [self.mockSession connection:self.dummyURLConnection didReceiveResponse:responseMock];
    STAssertFalse(authenticationCompleted, nil);
    STAssertNil(authenticationError, nil);

    NSString *badResponseString = @"iamanunparseablestringofgarbage>";
    NSData *responseData = [badResponseString dataUsingEncoding:NSASCIIStringEncoding];
    [self.mockSession connection:self.dummyURLConnection didReceiveData:responseData];
    STAssertFalse(authenticationCompleted, nil);
    STAssertNil(authenticationError, nil);
    
    [self.mockSession connectionDidFinishLoading:self.dummyURLConnection];    
    STAssertTrue(authenticationCompleted, nil);
    STAssertNotNil(authenticationError, nil);
    STAssertEqualObjects(authenticationError.domain, EvernoteSDKErrorDomain, nil);
    STAssertEquals(authenticationError.code, EDAMErrorCode_INTERNAL_ERROR, nil);    
}

- (void)testSuccessfulAuthentication
{
    [[[self.mockSession stub] andReturn:self.dummyURLConnection] connectionWithRequest:[OCMArg any]];
    
    [self.mockSession authenticateWithViewController:self.mockViewController completionHandler:^(NSError *error) {
        authenticationCompleted = YES;
        authenticationError = error;
    }];

    // start with the temp token response
    // HTTP OK response
    int statusCode = 200;
    id responseMock = [OCMockObject mockForClass:[NSHTTPURLResponse class]];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(statusCode)] statusCode];    
    [self.mockSession connection:self.dummyURLConnection didReceiveResponse:responseMock];
    STAssertFalse(authenticationCompleted, nil);
    STAssertNil(authenticationError, nil);

    NSString *tempTokenResponseString = @"oauth_token=en_oauth_test.12BF8802654.687474703A2F2F6C6F63616C686F73742F7E736574682F4544414D576562546573742F696E6465782E7068703F616374696F6E3D63616C6C6261636B.1FFF88DC670B03799613E5AC956B6E6D&oauth_token_secret=&oauth_callback_confirmed=true";
    NSData *tempTokenResponseData = [tempTokenResponseString dataUsingEncoding:NSASCIIStringEncoding];
    [self.mockSession connection:self.dummyURLConnection didReceiveData:tempTokenResponseData];
    STAssertFalse(authenticationCompleted, nil);
    STAssertNil(authenticationError, nil);

    // make sure EvernoteSession tried to open the embedded viewController/browser for the Evernote authorization
    [[self.mockSession expect] openOAuthViewControllerWithURL:[OCMArg any]];

    [self.mockSession connectionDidFinishLoading:self.dummyURLConnection];
    STAssertFalse(authenticationCompleted, nil);
    STAssertNil(authenticationError, nil);    
    [self.mockSession verify];

    // successful authentication will dismiss the modal popup
    [[self.mockViewController expect] dismissViewControllerAnimated:YES
 completion:^{
     NSString *urlString = @"en-dummyaccount-1234://response?action=oauthCallback&oauth_token=en_oauth_test.12BF88D95B9.687474703A2F2F6C6F63616C686F73742F7E736574682F4544414D576562546573742F696E6465782E7068703F616374696F6E3D63616C6C6261636B.AEDE24F1FAFD67D267E78D27D14F01D3&oauth_verifier=0D6A636CD623302F8D69DBB8DF76D86E";
     [self.mockSession oauthViewController:nil receivedOAuthCallbackURL:[NSURL URLWithString:urlString]];
     
     [self.mockViewController verify];
     
     // now we can poke the NSURLConnectionDelegate methods again, for the 4th step of OAuth.
     
     // connection:didReceiveResponse:
     [self.mockSession connection:self.dummyURLConnection didReceiveResponse:responseMock];
     STAssertFalse(authenticationCompleted, nil);
     STAssertNil(authenticationError, nil);
     
     // connection:didReceiveData:
     NSString *accessTokenResponseString = @"oauth_token=sometokenvalue&oauth_token_secret=&edam_noteStoreUrl=https%3A%2F%2Fsandbox.evernote.com%2Fedam%2Fnote%2Fshard%2Fs4&edam_userId=161&edam_webApiUrlPrefix=https%3A%2F%2Fsandbox.evernote.com%2Fshard%2Fs1%2F";
     NSData *accessTokenResponseData = [accessTokenResponseString dataUsingEncoding:NSASCIIStringEncoding];
     [self.mockSession connection:self.dummyURLConnection didReceiveData:accessTokenResponseData];
     STAssertFalse(authenticationCompleted, nil);
     STAssertNil(authenticationError, nil);
     
     // connection:DidFinishLoading:
     // make sure EvernoteSession tried to save credentials
     [[self.mockSession expect] saveCredentialsWithEdamUserId:@"161"
                                                 noteStoreUrl:@"https://sandbox.evernote.com/edam/note/shard/s4"
                                              webApiUrlPrefix:@"https://sandbox.evernote.com/shard/s1/"
                                          authenticationToken:@"sometokenvalue"];
     [self.mockSession connectionDidFinishLoading:self.dummyURLConnection];
     [self.mockSession verify];
     
     // and make sure our callback happened, without error.
     STAssertTrue(authenticationCompleted, nil);
     STAssertNil(authenticationError, nil);
     
     // holy moly, we're authenticated.
 }];
    
}

@end
