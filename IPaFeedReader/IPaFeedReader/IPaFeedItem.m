//
//  IPaFeedItem.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import "IPaFeedItem.h"

@implementation IPaFeedItem
-(NSDictionary *)others
{
    if (_others == nil) {
        _others = @{};
    }
    return _others;
}
@end
