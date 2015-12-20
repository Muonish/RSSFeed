//
//  RSSViewController.h
//  RSSFeed
//
//  Created by Valeryia Breshko on 12/19/15.
//  Copyright © 2015 Valeria Breshko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSParser.h"

@interface RSSViewController : UITableViewController <RSSParserDelegate>

@property (strong, atomic) NSMutableData *data;
@property (strong, atomic) NSMutableArray *topics;
@property (strong, atomic) NSMutableArray *feedByTopics;

@end
