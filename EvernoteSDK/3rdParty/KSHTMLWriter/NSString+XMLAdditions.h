//
//  NSString+XMLAdditions.h
//  Evernote
//
//  Created by Steve White on 10/5/07.
//  Copyright 2007 Evernote Corporation. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSString (XMLAdditions)

/**
 * Escape the standard 5 XML entities: &, <, >, ", '
 */
- (NSString *) stringByEscapingCriticalXMLEntities;
/**
 * Unescape the standard 5 XML entities: &, <, >, ", '
 */
- (NSString *) stringByUnescapingCrititcalXMLEntities;

@end
