//
//  IPaFeedReader.h
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaFeedInfo.h"
#import "IPaFeedItem.h"
// Errors & codes
#define IPaFRErrorDomain @"IPaFeedReaderErrorDomain"
#define IPaFRErrorCodeFeedParsingError 1
typedef void (^IPaFRCallback)(IPaFeedInfo*,NSArray*);
@interface IPaFeedReader : NSObject
-(instancetype)initWithFeedData:(NSData*)feedData withTextEncoding:(NSStringEncoding)textEncoding;

-(void)parseCompleted:(IPaFRCallback)completed;

@end
