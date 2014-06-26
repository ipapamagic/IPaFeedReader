//
//  IPaAtomFeed.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import "IPaAtomParser.h"
#import "IPaFeedItem.h"
#import "NSDate+IPaFeedParser.h"
// Empty XHTML elements ( <!ELEMENT br EMPTY> in http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd )
#define ELEMENT_IS_EMPTY(e) ([e isEqualToString:@"br"] || [e isEqualToString:@"img"] || [e isEqualToString:@"input"] || \
    [e isEqualToString:@"hr"] || [e isEqualToString:@"link"] || [e isEqualToString:@"base"] || \
    [e isEqualToString:@"basefont"] || [e isEqualToString:@"frame"] || [e isEqualToString:@"meta"] || \
    [e isEqualToString:@"area"] || [e isEqualToString:@"col"] || [e isEqualToString:@"param"])
@implementation IPaAtomParser
{
    BOOL parsingXHTML;
    NSString *xhtmlStartPath;
}
- (void)didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    [super didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
    
    // Parse content as structure (Atom feeds with element type="xhtml")
    // - Use elementName not qualifiedName to ignore XML namespaces for XHTML entities
    if (parsingXHTML) {
        
        // Open XHTML tag
        [self.currentText appendFormat:@"<%@", elementName];
        
        // Add attributes
        for (NSString *key in attributeDict) {
            [self.currentText appendFormat:@" %@=\"%@\"", key,
             attributeDict[key]];
//            [currentText appendFormat:@" %@=\"%@\"", key,[[attributeDict objectForKey:key] stringByEncodingHTMLEntities]];
        }
        
        // End tag or close
        if (ELEMENT_IS_EMPTY(elementName)) {
            [self.currentText appendString:@" />"];
        } else {
            [self.currentText appendString:@">"];
        }
        
        // Dont continue
        return;
        
    }
    if ([self.currentPath isEqualToString:@"entry"]) {
        self.currentItem = [[IPaFeedItem alloc] init];
    }
    else {
        NSString *typeAttribute = [attributeDict objectForKey:@"type"];
        if (typeAttribute && [typeAttribute isEqualToString:@"xhtml"]) {
            
            // Start parsing structure as content
            parsingXHTML = YES;
            
            // Remember path so we can stop parsing structure when element ends
            xhtmlStartPath = [self.currentPath copy];
            
        }

    }
    
}
- (void)didEndElement:(NSString *)elementName
         namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (parsingXHTML) {
        //
        if (self.currentPath.length > xhtmlStartPath.length) {
            
            // Close XHTML tag unless it is an empty element
            if (!ELEMENT_IS_EMPTY(elementName)) {
                [self.currentText appendFormat:@"</%@>", elementName];
            }
            
            [super didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
            // Return
            return;
            
        }
        
        
        
        parsingXHTML = NO;
        xhtmlStartPath = nil;
    }
    NSString *processText = [self.currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (self.currentItem) {
        
        
        if ([qName isEqualToString:@"entry"]) {
            [self.delegate onParser:self readFeedItem:self.currentItem];
            self.currentItem = nil;
        }
        else if ([qName isEqualToString:@"link"]) {
            if (self.currentAttribute) {
                NSString *rel = self.currentAttribute[@"rel"];
                if (rel) {
                    
                    // Use as link if rel == alternate
                    if ([rel isEqualToString:@"alternate"]) {
                        self.currentItem.link = self.currentAttribute[@"href"]; // Can be added to MWFeedItem or MWFeedInfo
                    }
                    
                    // Use as enclosure if rel == enclosure
                    else if ([rel isEqualToString:@"enclosure"]) {
                        NSString *encURL = nil;
                        NSString *encType = nil;
                        NSNumber *encLength = nil;
                        encURL = [self.currentAttribute objectForKey:@"href"];
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
                    
                }
            }
        }
        else if ([qName isEqualToString:@"updated"]) {
            self.currentItem.updated = [NSDate dateFromRFC3339String:processText];
            
        }
        else if ([qName isEqualToString:@"published"]) {
            self.currentItem.date = [NSDate dateFromRFC3339String:processText];
            
        }
        else if ([qName isEqualToString:@"title"]) {
            
            self.currentItem.title = processText;
        }
        else if ([qName isEqualToString:@"id"]) {
            
            self.currentItem.identifier = processText;
        }
        else if ([qName isEqualToString:@"summary"]) {
            
            self.currentItem.summary = processText;
        }
        else if ([qName isEqualToString:@"content"]) {
            
            self.currentItem.content = processText;
        }
        else if ([qName isEqualToString:@"name"] || [qName isEqualToString:@"dc:creator"]) {
            
            self.currentItem.author = processText;
        }
    }
    else {
        //parse info
        if ([self.currentPath isEqualToString:@"title"]) {
            self.currentInfo.title = processText;
        }
        else if ([self.currentPath isEqualToString:@"description"]) {
            self.currentInfo.summary = processText;
        }
        else if ([self.currentPath isEqualToString:@"link"]) {
            NSString *rel = self.currentAttribute[@"rel"];
            if (rel) {
                // Use as link if rel == alternate
                if ([rel isEqualToString:@"alternate"]) {
                    self.currentInfo.link = self.currentAttribute[@"href"]; // Can be added to MWFeedItem or MWFeedInfo
                }
            }
        }
        
    }
    [super didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
}
@end
