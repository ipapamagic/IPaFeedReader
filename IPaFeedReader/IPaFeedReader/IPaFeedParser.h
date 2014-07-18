//
//  IPaFeedParser.h
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014 A Magic Stuio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPaFeedItem.h"
#import "IPaFeedInfo.h"
@protocol IPaFeedParserDelegate;
@interface IPaFeedParser : NSObject
@property (nonatomic,copy) NSMutableString *currentText;
@property (nonatomic,copy) NSString *currentPath;
@property (nonatomic,strong) IPaFeedInfo *currentInfo;
@property (nonatomic,strong) IPaFeedItem *currentItem;
@property (nonatomic,strong) NSDictionary *currentAttribute;
@property (nonatomic,weak) id <IPaFeedParserDelegate> delegate;
- (void)didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)foundCDATA:(NSData *)CDATABlock;
- (void)foundCharacters:(NSString *)string;
@end


@protocol IPaFeedParserDelegate <NSObject>
-(void)onParser:(IPaFeedParser*)parser readFeedItem:(IPaFeedItem*)item;
-(void)onFailWithParser:(IPaFeedParser*)parser;
@end