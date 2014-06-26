//
//  NSDate+IPaFeedParser.h
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (IPaFeedParser)
+ (NSDate *)dateFromRFC3339String:(NSString *)dateString;
+ (NSDate *)dateFromRFC822String:(NSString *)dateString;
@end
