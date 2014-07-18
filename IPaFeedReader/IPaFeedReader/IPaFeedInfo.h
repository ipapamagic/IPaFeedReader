//
//  IPaFeedInfo.h
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014 A Magic Stuio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaFeedInfo : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic,strong) NSDictionary *others;
@end
