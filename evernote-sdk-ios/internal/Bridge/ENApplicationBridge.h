//
//  ENApplicationBridge.h
//  EvernoteClipper
//
//  Created by Evernote Corporation on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
# import <UIKit/UIKit.h>
#else
# import <Cocoa/Cocoa.h>
#endif

#import "ENApplicationRequest.h"
#import "ENLinkNotebookRequest.h"
#import "ENNewNoteRequest.h"
#import "ENNoteViewRequest.h"
#import "ENResourceAttachment.h"
#import "ENSearchRequest.h"
#import "ENAuthenticationRequest.h"

extern NSString * const kEN_ApplicationBridge_EvernoteNotInstalled;
extern NSString * const kEN_ApplicationBridge_InvalidRequestType;

@interface ENApplicationBridge : NSObject {

}

/*!
 @function
 @abstract   <#(description)#>
 @discussion <#(description)#>
 @param      <#(name) (description)#>
 @result     <#(description)#>
 */
+ (ENApplicationBridge *) newApplicationBridge;

/*!
 @function
 @abstract   <#(description)#>
 @discussion <#(description)#>
 @result     Returns YES if Evernote is installed.
 */
- (BOOL) isEvernoteInstalled;

/*!
 @function
 @abstract   <#(description)#>
 @discussion Returns an NSURL where the Evernote application can be downloaded from.  
 On the iPhone this will be a URL that invokes the App Store.
 @result     
 */
- (NSURL *) evernoteDownloadURL;

/*!
 @function
 @abstract   <#(description)#>
 @discussion <#(description)#>
 @param      <#(name) (description)#>
 */
- (void) performRequest:(id<ENApplicationRequest>)request;

/*!
 @function
 @abstract   <#(description)#>
 @discussion <#(description)#>
 @param      <#(name) (description)#>
 */
- (void) performRequest:(id<ENApplicationRequest>)request withCallbackURL:(NSURL *)callbackURL;

@end
