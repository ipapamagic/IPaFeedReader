//
//  IPaFeedParser.m
//  IPaFeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014 A Magic Stuio. All rights reserved.
//

#import "IPaFeedParser.h"

@implementation IPaFeedParser
-(instancetype)init

{
    self = [super init];
    self.currentInfo = [[IPaFeedInfo alloc] init];
    return self;
}
-(NSMutableString*)currentText
{
    if (_currentText == nil) {
        _currentText = [@"" mutableCopy];
    }
    return _currentText;
}
-(NSString*)currentPath
{
    if (_currentPath == nil) {
        _currentPath = @"";
    }
    return _currentPath;
}
- (void)didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    [self.currentText setString:@""];
    self.currentPath = [self.currentPath stringByAppendingPathComponent:qualifiedName];
    self.currentAttribute = attributeDict;
}
- (void)didEndElement:(NSString *)elementName
         namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    self.currentPath = [self.currentPath stringByDeletingLastPathComponent];
}
- (void)foundCDATA:(NSData *)CDATABlock
{
    // Try decoding with NSUTF8StringEncoding
	NSString *string = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    if (string) {
        [self.currentText appendString:string];
    }

}
- (void)foundCharacters:(NSString *)string
{
    [self.currentText appendString:string];
}

@end
