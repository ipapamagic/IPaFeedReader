//
//  DetailTableViewController.h
//  FeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IPaFeedReader/IPaFeedItem.h>
@interface DetailTableViewController : UITableViewController
@property (nonatomic,weak) IPaFeedItem *item;
@end
