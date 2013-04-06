//
//  KSXMLAttributes.h
//  Sandvox
//
//  Created by Mike on 19/11/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSXMLAttributes : NSObject <NSCopying>
{
@private
  NSMutableArray  *_attributes;
}

- (id)initWithXMLAttributes:(KSXMLAttributes *)info;

@property(nonatomic, copy) NSDictionary *attributesAsDictionary;
- (BOOL)hasAttributes;
- (void)addAttribute:(NSString *)attribute value:(id)value;

- (void)close;  // removes all attributes


@end
