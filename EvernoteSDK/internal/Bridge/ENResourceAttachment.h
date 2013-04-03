//
//  ENResourceAttachment.h
//  EvernoteClipper
//
//  Created by Evernote Corporation on 5/27/09.
//  Copyright 2009 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENApplicationRequest.h"

@interface ENResourceAttachment : NSObject<ENApplicationRequest> {
	NSData *mResourceData;
	NSString *mMimeType;
	NSString *mFilename;
  NSString *mFilepath;
}

@property (strong, nonatomic) NSData *resourceData;
@property (strong, nonatomic) NSString *mimeType;
@property (strong, nonatomic) NSString *filename;

@end
