//
//  RSSParser.h
//  RSSFeed
//
//  Created by Valeryia Breshko on 12/19/15.
//  Copyright © 2015 Valeria Breshko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSSParserDelegate;

@interface RSSParser : NSObject <NSXMLParserDelegate>

@property (weak, nonatomic) id <RSSParserDelegate> delegate;

@property (strong, nonatomic) NSXMLParser *xmlParser;
@property (weak, atomic) NSMutableArray *feedInTopic;
@property (strong, nonatomic) NSNumber *index;

@property (strong, nonatomic) NSString *element;  //now parsing element
@property (strong, nonatomic) NSMutableString *parsedTitle;
@property (strong, nonatomic) NSMutableString *parsedAuthor;
@property (strong, nonatomic) NSMutableString *parsedDate;
@property (strong, nonatomic) NSMutableString *parsedLink;
@property (strong, nonatomic) NSMutableString *parsedDescription;

- (id)initWithContentsOfURL:(NSURL *)url;
- (BOOL)parse;

@end

@protocol RSSParserDelegate <NSObject>

@required
- (void) itemInSectionLoaded: (NSNumber*) sectionIndex;
@end
