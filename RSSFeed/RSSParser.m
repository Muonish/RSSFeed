//
//  RSSParser.m
//  RSSFeed
//
//  Created by Valeryia Breshko on 12/19/15.
//  Copyright © 2015 Valeria Breshko. All rights reserved.
//

#import "RSSParser.h"
#import "HTMLParser.h"

@implementation RSSParser

- (id)initWithContentsOfURL:(NSURL *)url {
    if ( self = [super init] ) {
        self.xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [self.xmlParser setDelegate:self];
    }

    return self;
}

- (BOOL)parse {
    return [self.xmlParser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    self.element = elementName;

    if ([self.element isEqualToString:@"item"]) {
        self.parsedTitle = [[NSMutableString alloc] init];
        self.parsedAuthor = [[NSMutableString alloc] init];
        self.parsedDate = [[NSMutableString alloc] init];
        self.parsedLink = [[NSMutableString alloc] init];
        self.parsedDescription = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if ([self.element isEqualToString:@"title"]) {
        [self.parsedTitle appendString:string];
    } else if ([self.element isEqualToString:@"link"]) {
        [self.parsedLink appendString:string];
    } else if ([self.element isEqualToString:@"author"]) {
        [self.parsedAuthor appendString:string];
    } else if ([self.element isEqualToString:@"pubDate"]) {
        [self.parsedDate appendString:string];
    } else if ([self.element isEqualToString:@"description"]) {
        [self.parsedDescription appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {

    if ([elementName isEqualToString:@"item"]) {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];

        NSString* link = self.parsedLink;
        link = [link stringByReplacingOccurrencesOfString:@"\n " withString:@""];
        link = [link stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        [item setObject:self.parsedTitle forKey:@"title"];
        [item setObject:link forKey:@"link"];
        [item setObject:self.parsedAuthor forKey:@"author"];
        [item setObject:self.parsedDate forKey:@"pubDate"];
        [item setObject:self.parsedDescription forKey:@"description"];

        NSString *imgUrl = [self parseImgUrlInString:self.parsedDescription];

        if (imgUrl) {
            [item setObject:imgUrl forKey:@"imgLink"];
        }
        
        [self.feedInTopic addObject:item];

        [self.delegate itemInSectionLoaded:self.index];
    }
}

//- (void)parserDidEndDocument:(NSXMLParser *)parser {
//
//}

- (NSString *)parseImgUrlInString:(NSString *)text{
    NSError *error = nil;
    NSString *result = nil;
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:self.parsedDescription error:&error];
    HTMLNode *bodyNode = [parser body];

    HTMLNode *imgNode = [bodyNode findChildTag:@"img"];
    result = [imgNode getAttributeNamed:@"src"];

    return result;
}



@end
