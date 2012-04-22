//
//  EvernoteSDK.h
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 4/22/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "EvernoteAsyncUserStore.h"
#import "EvernoteAsyncNoteStore.h"
#import "EvernoteNoteStore.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"

// For other application-level error codes, see EDAMErrorCode in EDAMErrors.h.
typedef enum {
    EvernoteSDKErrorCode_TRANSPORT_ERROR = -3000,
} EvernoteSDKErrorCode;

// Evernote SDK NSError error domain.
extern NSString *const EvernoteSDKErrorDomain;

