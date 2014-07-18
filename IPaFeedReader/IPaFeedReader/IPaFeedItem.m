//
//  IPaFeedItem.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014 A Magic Stuio. All rights reserved.
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
- (id)copyWithZone:(NSZone *)zone
{
    IPaFeedItem *newItem = [[IPaFeedItem alloc] init];
    newItem.identifier = self.identifier;
    newItem.title = self.title;
    newItem.link = self.link;
    newItem.date = [self.date copy];
    newItem.enclosures = [self.date copy];
    newItem.summary = self.summary;
    newItem.content = self.content;
    newItem.author = self.author;
    newItem.updated = [self.updated copy];
    newItem.others = [self.others copy];

    return newItem;
}
@end
