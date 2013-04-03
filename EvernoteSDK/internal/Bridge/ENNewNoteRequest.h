//
//  ENNewNoteRequest.h
//  EvernoteClipper
//
//  Created by Evernote Corporation on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENApplicationRequest.h"
#import "ENResourceAttachment.h"

@interface ENNewNoteRequest : NSObject<ENApplicationRequest> {
	NSString *mTitle;
	NSString *mContent;
	NSString *mContentMimeType;
	NSURL *mSourceURL;
	NSString *mSourceApplication;
	NSArray *mTagNames;
	NSArray *mResourceAttachments;
	
	// These are double because CLLocation might not exist on
	// the given platform...
	double mLatitude;
	double mLongitude;
	double mAltitude;
}

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *contentMimeType;
@property (strong, nonatomic) NSURL *sourceURL;
@property (strong, nonatomic) NSString *sourceApplication;
@property (strong, nonatomic) NSArray *tagNames;
@property (nonatomic, copy) NSString* notebookGUID;
@property (nonatomic,copy) NSString* consumerKey;

@property (strong, nonatomic) NSArray *resourceAttachments;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double altitude;


- (void) addResourceAttachment:(ENResourceAttachment *)resourceAttachment;
- (void) removeResourceAttachment:(ENResourceAttachment *)resourceAttachment;

@end
