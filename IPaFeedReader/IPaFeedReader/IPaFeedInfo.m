//
//  IPaFeedInfo.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import "IPaFeedInfo.h"

@implementation IPaFeedInfo
-(NSDictionary *)others
{
    if (_others == nil) {
        _others = @{};
    }
    return _others;
}
@end
