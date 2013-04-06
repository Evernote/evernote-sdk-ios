/*
 * ENAPI.h
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
#import "EDAM.h"
#import "ENAPI.h"
#import "EvernoteSDK.h"

@interface ENAPI ()

@property (nonatomic,strong) NSArray* errorDescriptions;

@end

@implementation ENAPI

@synthesize session = _session;
@dynamic noteStore;
@dynamic userStore;

typedef void (^EvernoteErrorBlock) (NSError *error);

- (id)initWithSession:(EvernoteSession *)session
{
    self = [super init];
    if (self) {
        self.session = session;
        self.errorDescriptions = @[@"No information available about the error",
                                   @"The format of the request data was incorrect",
                                   @"Not permitted to perform action",
                                   @"Unexpected problem with the service",
                                   @"A required parameter/field was absent",
                                   @"Operation denied due to data model limit",
                                   @"Operation denied due to user storage limit",
                                   @"Username and/or password incorrect",
                                   @"Authentication token expired",
                                   @"Change denied due to data model conflict",
                                   @"Content of submitted note was malformed",
                                   @"Service shard with account data is temporarily down",
                                   @"Operation denied due to data model limit, where something such as a string length was too short",
                                   @"Operation denied due to data model limit, where something such as a string length was too long",
                                   @"Operation denied due to data model limit, where there were too few of something.",
                                   @"Operation denied due to data model limit, where there were too many of something.",
                                   @"Operation denied because it is currently unsupported.",
                                   @"Operation denied because access to the corresponding object is prohibited in response to a take-down notice."];
    }
    return self;
}

- (EDAMNoteStoreClient *)noteStore
{
    return [self.session noteStore];
}

- (EDAMUserStoreClient *)userStore
{
    return [self.session userStore];
}

- (EDAMNoteStoreClient *)businessNoteStore
{
    return [self.session businessNoteStore];
}

- (NSError *)errorFromNSException:(NSException *)exception
{
    if (exception) {
        int errorCode = EDAMErrorCode_UNKNOWN;
        if ([exception respondsToSelector:@selector(errorCode)]) {
            // Evernote Thrift exception classes have an errorCode property
            errorCode = [(id)exception errorCode];
        } else if ([exception isKindOfClass:[TException class]]) {
            // treat any Thrift errors as a transport error
            // we could create separate error codes for the various TException subclasses
            errorCode = EvernoteSDKErrorCode_TRANSPORT_ERROR;
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:exception.userInfo];
        if(errorCode>=EDAMErrorCode_UNKNOWN && errorCode<=EDAMErrorCode_UNSUPPORTED_OPERATION) {
            // being defensive here
            if(self.errorDescriptions && self.errorDescriptions.count>=EDAMErrorCode_UNSUPPORTED_OPERATION) {
                if(userInfo[NSLocalizedDescriptionKey] == nil) {
                    userInfo[NSLocalizedDescriptionKey] = self.errorDescriptions[errorCode-1];
                }
            }
        }
        if ([exception respondsToSelector:@selector(parameter)]) {
            NSString *parameter = [(id)exception parameter];
            if (parameter) {
                [userInfo setValue:parameter forKey:@"parameter"];
            }
        }
        return [NSError errorWithDomain:EvernoteSDKErrorDomain code:errorCode userInfo:userInfo];
    }
    return nil;
}

- (void)invokeAsyncBoolBlock:(BOOL(^)())block
                     success:(void(^)(BOOL val))success
                     failure:(void(^)(NSError *error))failure
{
    dispatch_async(self.session.queue, ^(void) {
        __block BOOL retVal = NO;
        @try {
            if (block) {
                retVal = block();
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   if (success) {
                                       success(retVal);
                                   }
                               });
            }
        }
        @catch (NSException *exception) {
            NSError *error = [self errorFromNSException:exception];
            [self processError:failure withError:error];
        }
    });
}

- (void)invokeAsyncInt32Block:(int32_t(^)())block
                      success:(void(^)(int32_t val))success
                      failure:(void(^)(NSError *error))failure
{
    dispatch_async(self.session.queue, ^(void) {
        __block int32_t retVal = -1;
        @try {
            if (block) {
                retVal = block();
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   if (success) {
                                       success(retVal);
                                   }
                               });
            }
        }
        @catch (NSException *exception) {
            NSError *error = [self errorFromNSException:exception];
            [self processError:failure withError:error];
        }
    });
}

// use id instead of NSObject* so block type-checking is happy
- (void)invokeAsyncIdBlock:(id(^)())block
                   success:(void(^)(id))success
                   failure:(void(^)(NSError *error))failure
{
    dispatch_async(self.session.queue, ^(void) {
        id retVal = nil;
        @try {
            if (block) {
                retVal = block();
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   if (success) {
                                       success(retVal);
                                   }
                               });
            }
        }
        @catch (NSException *exception) {
            NSError *error = [self errorFromNSException:exception];
            [self processError:failure withError:error];
        }
    });
}

- (void)invokeAsyncVoidBlock:(void(^)())block
                     success:(void(^)())success
                     failure:(void(^)(NSError *error))failure
{
    dispatch_async(self.session.queue, ^(void) {
        @try {
            if (block) {
                block();
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   if (success) {
                                       success();
                                   }
                               });
            }
        }
        @catch (NSException *exception) {
            NSError *error = [self errorFromNSException:exception];
            [self processError:failure withError:error];
        }
    });
}

- (void)processError:(EvernoteErrorBlock)errorBlock withError:(NSError*)error {
    // See if we can trigger OAuth automatically
    BOOL didTriggerAuth = NO;
    if([EvernoteSession isTokenExpiredWithError:error]) {
        [self.session logout];
        UIViewController* topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if(!topVC.presentedViewController && topVC.isViewLoaded) {
            didTriggerAuth = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.session authenticateWithViewController:topVC completionHandler:^(NSError *authError) {
                    if(errorBlock) {
                        errorBlock(authError);
                    }
                }];
            });
        }
        
    }
    // If we were not able to trigger auth, send the error over to the client
    if(didTriggerAuth==NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(errorBlock) {
                errorBlock(error);
            }
        });
    }
}

@end
