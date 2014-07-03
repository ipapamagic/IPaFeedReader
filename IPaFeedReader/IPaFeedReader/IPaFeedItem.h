//
//  IPaFeedItem.h
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaFeedItem :NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *enclosures;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, strong) NSDate *updated;
@property (nonatomic,strong) NSDictionary *others;
@end
