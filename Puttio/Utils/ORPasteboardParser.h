//
//  ORPasteboardParser.h
//  Puttio
//
//  Created by orta therox on 08/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORPasteboardParser : NSObject
+ (NSSet *)submitableURLsInPasteboard;
@end
