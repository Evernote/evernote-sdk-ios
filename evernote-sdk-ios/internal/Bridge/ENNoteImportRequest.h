//
//  ENNoteImportRequest.h
//  Evernote
//
//  Created by Steve White on 7/20/12.
//  Copyright (c) 2012 Evernote Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENApplicationRequest.h"

@interface ENNoteImportRequest : NSObject<ENApplicationRequest>

@property (strong, nonatomic) NSString *file;
@property (assign, nonatomic) BOOL createNotebook;

+ (ENNoteImportRequest *) importRequestForFile:(NSString *)file;

@end
