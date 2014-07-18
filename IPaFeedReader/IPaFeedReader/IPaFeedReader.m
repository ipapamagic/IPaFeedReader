//
//  IPaFeedReader.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014 A Magic Stuio. All rights reserved.
//

#import "IPaFeedReader.h"
#import "IPaRSSParser.h"
#import "IPaRSS1Parser.h"
#import "IPaAtomParser.h"




@interface IPaFeedReader () <NSXMLParserDelegate , IPaFeedParserDelegate>
@property (nonatomic,copy) IPaFRCallback onParseCompleted;
@end
@implementation IPaFeedReader
{
    NSXMLParser *xmlParser;
    NSInteger feedParserOption;
    
    NSMutableArray *items;
    IPaFeedParser *currentParser;
}
-(instancetype)initWithFeedData:(NSData*)feedData withTextEncoding:(NSStringEncoding)textEncoding
{
    self = [super init];
    
    if (textEncoding != NSUTF8StringEncoding) {
        //check encoding is utf8
        //if not convert to utf8
        
        
        
        NSString *feedString = [[NSString alloc] initWithData:feedData encoding:textEncoding];
        
        // Parse data
        if (feedString) {
            
            // Set XML encoding to UTF-8
            if ([feedString hasPrefix:@"<?xml"]) {
                NSRange range = [feedString rangeOfString:@"?>"];
                if (range.location != NSNotFound) {
                    NSString *xmlDec = [feedString substringToIndex:range.location];
                    if ([xmlDec rangeOfString:@"encoding=\"UTF-8\""
                                      options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        range = [xmlDec rangeOfString:@"encoding=\""];
                        if (range.location != NSNotFound) {
                            NSUInteger location = range.location+range.length;
                            NSRange rangeEnd = [xmlDec rangeOfString:@"\"" options:0 range:NSMakeRange(location, [xmlDec length] - location)];
                            if (rangeEnd.location != NSNotFound) {
                                feedString = [feedString stringByReplacingCharactersInRange:NSMakeRange(range.location,rangeEnd.location+rangeEnd.length-range.location)                                    withString:@"encoding=\"UTF-8\""];
                            }
                        }
                    }
                }
            }
            
            // Convert string to UTF-8 data
            
            
            feedData = (feedString)?[feedString dataUsingEncoding:NSUTF8StringEncoding]:nil;
            
            
        }
        
    }

    // Create NSXMLParser
    if (feedData) {
        xmlParser = [[NSXMLParser alloc] initWithData:feedData];
        xmlParser.delegate = self;
        [xmlParser setShouldProcessNamespaces:YES];
    }
    return self;
}
-(void)parseCompleted:(IPaFRCallback)completed;
{
    if (!xmlParser) {
        if (completed) {
            completed(nil,nil);
        }
        [self parsingFailedWithErrorCode:IPaFRErrorCodeFeedParsingError andDescription:@"XML parser not initial correctly"];
        return;
    }
    items = [@[] mutableCopy];
    self.onParseCompleted = completed;
    [xmlParser parse];
    
}
- (void)parsingFailedWithErrorCode:(NSInteger)code andDescription:(NSString *)description {
	// Create error
//    NSError *error = [NSError errorWithDomain:IPaFPErrorDomain
//                                         code:code
//                                     userInfo:[NSDictionary dictionaryWithObject:description
//                                                                          forKey:NSLocalizedDescriptionKey]];
    if (xmlParser) {
        [xmlParser abortParsing];
        
    }
    
    if (self.onParseCompleted) {
        self.onParseCompleted(nil,nil);
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
	if (self.onParseCompleted != nil) {
        self.onParseCompleted(currentParser.currentInfo,items);
    }
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    if (currentParser == nil) {
        if ([qualifiedName isEqualToString:@"rss"]) {
            currentParser = [[IPaRSSParser alloc] init];
        }
        else if ([qualifiedName isEqualToString:@"rdf:RDF"]) {
            currentParser = [[IPaRSS1Parser alloc] init];
        }
        else if ([qualifiedName isEqualToString:@"feed"]) {
            currentParser = [[IPaAtomParser alloc] init];
        }
        else {
            
            // Invalid format so fail
            [self parsingFailedWithErrorCode:IPaFRErrorCodeFeedParsingError
                              andDescription:@"can not identify feed type."];
            return;
        }
        currentParser.delegate = self;
        return;
    }
	[currentParser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qualifiedName attributes:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (!([qName isEqualToString:@"rss"] || [qName isEqualToString:@"rdf:RDF"] || [qName isEqualToString:@"feed"])) {
        [currentParser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    }
}

//- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName
//			forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue {
//	MWXMLLog(@"NSXMLParser: foundAttributeDeclarationWithName: %@", attributeName);
//}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {

    [currentParser foundCDATA:CDATABlock];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
    [currentParser foundCharacters:string];
	
}



// Call if parsing error occured or parse was aborted
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	// Fail with error
	[self parsingFailedWithErrorCode:IPaFRErrorCodeFeedParsingError andDescription:[parseError localizedDescription]];
	
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
	
	// Fail with error
	[self parsingFailedWithErrorCode:IPaFRErrorCodeFeedParsingError andDescription:[validError localizedDescription]];
	
}
#pragma mark - IPaFeedParserDelegate
-(void)onParser:(IPaFeedParser*)parser readFeedItem:(IPaFeedItem*)item {
    [items addObject:item];
}
-(void)onFailWithParser:(IPaFeedParser*)parser {
    [self parsingFailedWithErrorCode:IPaFRErrorCodeFeedParsingError andDescription:@"Parser fail!"];

}


@end
