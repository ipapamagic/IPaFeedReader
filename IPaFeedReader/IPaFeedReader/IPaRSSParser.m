//
//  IPaRSSParser.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import "IPaRSSParser.h"
#import "IPaFeedItem.h"
#import "NSDate+IPaFeedParser.h"
@implementation IPaRSSParser
{
}

- (void)didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    [super didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    
    
    if ([self.currentPath isEqualToString:@"channel/item"]) {
        self.currentItem = [[IPaFeedItem alloc] init];
    }
    
    
}
- (void)didEndElement:(NSString *)elementName
         namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    NSString *processText = [self.currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (self.currentItem) {
        
        
        if ([qName isEqualToString:@"item"]) {
            [self.delegate onParser:self readFeedItem:self.currentItem];
            self.currentItem = nil;
        }
        else if ([qName isEqualToString:@"enclosure"]) {
            NSString *encURL = nil;
            NSString *encType = nil;
            NSNumber *encLength = nil;
            encURL = [self.currentAttribute objectForKey:@"url"];
            encType = [self.currentAttribute objectForKey:@"type"];
            encLength =@([((NSString *)[self.currentAttribute objectForKey:@"length"]) longLongValue]);
            if (encURL) {
                NSMutableDictionary *enclosure = [[NSMutableDictionary alloc] initWithCapacity:3];
                [enclosure setObject:encURL forKey:@"url"];
                if (encType) {
                    [enclosure setObject:encType forKey:@"type"];
                }
                if (encLength) {
                    [enclosure setObject:encLength forKey:@"length"];
                }
                if (enclosure) {
                    if (self.currentItem.enclosures) {
                        self.currentItem.enclosures = [self.currentItem.enclosures arrayByAddingObject:enclosure];
                    } else {
                        self.currentItem.enclosures = [NSArray arrayWithObject:enclosure];
                    }
                }
            }
        }
        else if ([qName isEqualToString:@"pubDate"]) {
            self.currentItem.date = [NSDate dateFromRFC822String:processText];
        }
        else if ([qName isEqualToString:@"dc:date"]) {
            self.currentItem.date = [NSDate dateFromRFC3339String:processText];

        }
        else if ([qName isEqualToString:@"title"]) {
            
            self.currentItem.title = processText;
        }
        else if ([qName isEqualToString:@"link"]) {
            
            self.currentItem.link = processText;
        }
        else if ([qName isEqualToString:@"guid"]) {
            
            self.currentItem.identifier = processText;
        }
        else if ([qName isEqualToString:@"description"]) {
            
            self.currentItem.summary = processText;
        }
        else if ([qName isEqualToString:@"content:encoded"]) {
            
            self.currentItem.content = processText;
        }
        else if ([qName isEqualToString:@"dc:creator"] || [qName isEqualToString:@"author"]) {
            
            self.currentItem.author = processText;
        }
    }
    else {
        //parse info
        if ([self.currentPath isEqualToString:@"channel/title"]) {
            self.currentInfo.title = processText;
        }
        else if ([self.currentPath isEqualToString:@"channel/description"]) {
            self.currentInfo.summary = processText;
        }
        else if ([self.currentPath isEqualToString:@"channel/link"]) {
            self.currentInfo.link = processText;
        }
    }
    [super didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];        
}

@end
