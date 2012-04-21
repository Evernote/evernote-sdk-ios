//
//  EvernoteAPI.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/20/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EDAM.h"
#import "EvernoteAPI.h"
#import "Thrift.h"

typedef void (^VoidBlock)();
typedef int32_t (^IntBlock)();
typedef NSObject *(^ObjBlock)();

@interface EvernoteAPI()

@property (nonatomic, retain) EvernoteSession *session;
@property (nonatomic, readonly) EDAMNoteStoreClient *noteStore;
@property (nonatomic, readonly) EDAMNoteStoreClient *userStore;

// fill in (possibly creating) an NSError from a given NSException.
- (void)populateNSError:(NSError **)error fromEDAMUserException:(EDAMUserException *)exception;
- (void)populateNSError:(NSError **)error fromEDAMSystemException:(EDAMSystemException *)exception;
- (void)populateNSError:(NSError **)error fromNSException:(NSException *)exception;

// "safe invoke" various blocks, with try/catch wrapping.
- (void)invokeVoidBlock:(void(^)())block withError:(NSError **)error;
- (int32_t)invokeIntBlock:(int32_t(^)())block withError:(NSError **)error;
- (NSObject *)invokeObjBlock:(NSObject *(^)())block withError:(NSError **)error;

@end

@implementation EvernoteAPI

@synthesize session = _session;
@dynamic noteStore;
@dynamic userStore;

+ (EvernoteAPI *)api
{
    EvernoteAPI *api = [[[EvernoteAPI alloc] initWithSession:[EvernoteSession sharedSession]] autorelease];
    return api;
}

- (void)dealloc
{
    [_session release];
    [super dealloc];
}

- (id)initWithSession:(EvernoteSession *)session
{
    self = [super init];
    if (self) {
        self.session = session;
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

- (void)populateNSError:(NSError **)error fromEDAMUserException:(EDAMUserException *)exception
{
    if (exception) {
        *error = [NSError errorWithDomain:kEvernoteSDKErrorDomain code:exception.errorCode userInfo:exception.userInfo];
    }
}

- (void)populateNSError:(NSError **)error fromEDAMSystemException:(EDAMSystemException *)exception
{
    if (exception) {
        *error = [NSError errorWithDomain:kEvernoteSDKErrorDomain code:exception.errorCode userInfo:exception.userInfo];
    }
}

- (void)populateNSError:(NSError **)error fromNSException:(NSException *)exception
{
    if (exception) {
        *error = [NSError errorWithDomain:kEvernoteSDKErrorDomain code:kEvernoteSDKErrorUnknown userInfo:exception.userInfo];
    }
}

- (void)invokeVoidBlock:(void(^)())block withError:(NSError **)error
{
    @try {
        block();
    }
    @catch (EDAMUserException *exception) {
        [self populateNSError:error fromEDAMUserException:exception];  
    }
    @catch (EDAMSystemException *exception) {
        [self populateNSError:error fromEDAMSystemException:exception];      
    }
    @catch (NSException *exception) {
        [self populateNSError:error fromNSException:exception];
    }
    @finally {
    }
}

- (int32_t)invokeIntBlock:(int32_t(^)())block withError:(NSError **)error
{
    int32_t retVal = 0;
    @try {
        retVal = block();
    }
    @catch (EDAMUserException *exception) {
        [self populateNSError:error fromEDAMUserException:exception];  
    }
    @catch (EDAMSystemException *exception) {
        [self populateNSError:error fromEDAMSystemException:exception];      
    }
    @catch (NSException *exception) {
        [self populateNSError:error fromNSException:exception];
    }
    @finally {
    }  
    return retVal;
}

- (NSObject *)invokeObjBlock:(NSObject *(^)())block  withError:(NSError **)error
{
    NSObject *retVal = nil;
    @try {
        retVal = block();
    }
    @catch (EDAMUserException *exception) {
        [self populateNSError:error fromEDAMUserException:exception];  
    }
    @catch (EDAMSystemException *exception) {
        [self populateNSError:error fromEDAMSystemException:exception];      
    }
    @catch (NSException *exception) {
        [self populateNSError:error fromNSException:exception];
    }
    @finally {
    }  
    return retVal;   
}

#pragma mark - NoteStore

- (EDAMSyncState *)getSyncStateWithError:(NSError **)error 
{
    return (EDAMSyncState *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSyncState:self.session.authenticationToken];
    } withError:error];
}

- (EDAMSyncChunk *)getSyncChunkAfterUSN:(int32_t)afterUSN 
                             maxEntries:(int32_t)maxEntries
                           fullSyncOnly:(BOOL)fullSyncOnly
                                  error:(NSError **)error
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:fullSyncOnly];
    } withError:error];
}

- (EDAMSyncChunk *)getFilteredSyncChunkAfterUSN:(int32_t)afterUSN
                                     maxEntries:(int32_t)maxEntries
                                         filter:(EDAMSyncChunkFilter *)filter
                                          error:(NSError **)error
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getFilteredSyncChunk:self.session.authenticationToken:afterUSN:maxEntries:filter];
    } withError:error];
}

- (EDAMSyncState *)getLinkedNotebookSyncState:(EDAMLinkedNotebook *)linkedNotebook
                                        error:(NSError **)error
{
    return (EDAMSyncState *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getLinkedNotebookSyncState:self.session.authenticationToken:linkedNotebook];
    } withError:error];
}

- (NSArray *)listNotebooksWithError:(NSError **)error
{
    return (NSArray *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore listNotebooks:self.session.authenticationToken];
    } withError:error];
}

- (EDAMNotebook *)getNotebookWithGuid:(EDAMGuid)guid 
                                error:(NSError **)error
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getNotebook:self.session.authenticationToken:guid];
    } withError:error];
}

- (EDAMSyncChunk *)getLinkedNotebookSyncChunk:(EDAMLinkedNotebook *)linkedNotebook
                                     afterUSN:(int32_t)afterUSN
                                   maxEntries:(int32_t) maxEntries
                                 fullSyncOnly:(BOOL)fullSyncOnly
                                        error:(NSError **)error
{
    return (EDAMSyncChunk *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getLinkedNotebookSyncChunk:self.session.authenticationToken:linkedNotebook:afterUSN:maxEntries:fullSyncOnly];
    } withError:error];
}

- (EDAMNotebook *)getDefaultNotebookWithError:(NSError **)error
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore getDefaultNotebook:self.session.authenticationToken];
    } withError:error];
}

- (EDAMNotebook *)createNotebook:(EDAMNotebook *)notebook
                           error:(NSError **)error
{
    return (EDAMNotebook *)[self invokeObjBlock:^NSObject *() {
        return [self.noteStore createNotebook:self.session.authenticationToken:notebook];
    } withError:error];
}

@end
