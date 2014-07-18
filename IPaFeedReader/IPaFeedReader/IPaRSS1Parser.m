//
//  IPaRSS1Parser.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014 A Magic Stuio. All rights reserved.
//

#import "IPaRSS1Parser.h"
#import "IPaFeedItem.h"
#import "NSDate+IPaFeedParser.h"
@implementation IPaRSS1Parser

- (void)didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    [super didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    
    
    if ([self.currentPath isEqualToString:@"item"]) {
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
        else if ([qName isEqualToString:@"enc:enclosure"]) {
            NSString *encURL = nil;
            NSString *encType = nil;
            NSNumber *encLength = nil;
            encURL = [self.currentAttribute objectForKey:@"rdf:resource"];
            encType = [self.currentAttribute objectForKey:@"enc:type"];
            encLength =@([((NSString *)[self.currentAttribute objectForKey:@"enc:length"]) longLongValue]);
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
       
        else if ([qName isEqualToString:@"dc:date"]) {
            self.currentItem.date = [NSDate dateFromRFC3339String:processText];
            
        }
        else if ([qName isEqualToString:@"title"]) {
            
            self.currentItem.title = processText;
        }
        else if ([qName isEqualToString:@"link"]) {
            
            self.currentItem.link = processText;
        }
        else if ([qName isEqualToString:@"dc:identifier"]) {
            
            self.currentItem.identifier = processText;
        }
        else if ([qName isEqualToString:@"description"]) {
            
            self.currentItem.summary = processText;
        }
        else if ([qName isEqualToString:@"content:encoded"]) {
            
            self.currentItem.content = processText;
        }
        else if ([qName isEqualToString:@"dc:creator"]) {
            
            self.currentItem.author = processText;
        }
        else {
            NSMutableDictionary *others = [self.currentItem.others mutableCopy];
            others[qName] = processText;
            self.currentItem.others = others;
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
        else {
            NSMutableDictionary *others = [self.currentInfo.others mutableCopy];
            others[qName] = processText;
            self.currentInfo.others = others;
        }

    }
    [super didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];

}
@end
