//
//  RSSViewController.m
//  RSSFeed
//
//  Created by Valeryia Breshko on 12/19/15.
//  Copyright © 2015 Valeria Breshko. All rights reserved.
//

#import "RSSViewController.h"
#import "DetailViewController.h"
#import "RSSViewCell.h"
#import "HTMLParser.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface RSSViewController ()

@end

@implementation RSSViewController

static NSString *const cLink = @"http://www.economist.com";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.topics = [[NSMutableArray alloc] init];
    self.feedByTopics = [[NSMutableArray alloc] init];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self parseTopics];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RSSParser Delegate

- (void)itemInSectionLoaded: (NSNumber *) sectionIndex{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Parsing

- (void)parseTopics {
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"%@/rss",cLink]]];
    HTMLParser *htmlParser = [[HTMLParser alloc] initWithData:data
                                                        error:&error];
    HTMLNode *bodyNode = [htmlParser body];

    NSArray *divNodes = [bodyNode findChildTags:@"div"];

    for (HTMLNode *divNode in divNodes) {
        if ([[divNode getAttributeNamed:@"class"] isEqualToString:@"ec-rss-links-left grid-3"]) {
            NSArray *ulNodes = [divNode findChildTags:@"ul"];
            HTMLNode *ulNode = [ulNodes firstObject];

            NSArray *aNodes = [ulNode findChildTags:@"a"];

            for (HTMLNode *aNode in aNodes) {
                NSMutableDictionary *topic = [[NSMutableDictionary alloc] init];
                [topic setObject:[aNode.firstChild rawContents] forKey:@"title"];
                [topic setObject:[NSString stringWithFormat:@"%@%@", cLink,
                                  [aNode getAttributeNamed:@"href"] ]
                          forKey:@"link"];

                [self startParsingTopic:topic];

            }
        }
    }
}

- (void)startParsingTopic: (NSDictionary *)topic{

    [self.topics addObject:topic];
    [self.feedByTopics addObject:[[NSMutableArray alloc] init]];

    NSURL *url = [NSURL URLWithString:[topic objectForKey:@"link"]];
    RSSParser *parser = [[RSSParser alloc] initWithContentsOfURL:url];
    
    parser.feedInTopic = self.feedByTopics.lastObject;
    parser.index = [NSNumber numberWithInt:(int)self.feedByTopics.count - 1];
    parser.delegate = self;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [parser parse];
    });
}

- (NSString *)convertLocalDate:(NSString *)dateStr {

    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormat setDateFormat:@"ccc, d MMM yyyy HH:mm:ss Z\n "];
    NSDate *date = [dateFormat dateFromString:dateStr];

     NSString *localizedDateTime = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterShortStyle];
    return localizedDateTime;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.topics.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedByTopics[section] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.feedByTopics[indexPath.section][indexPath.row];
    [cell setValue:[item objectForKey:@"title"] forKeyPath:@"title.text"];
    [cell setValue:[item objectForKey:@"author"]  forKeyPath:@"author.text"];
    [cell setValue:[self convertLocalDate:[item objectForKey:@"pubDate"]]
        forKeyPath:@"date.text"];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *item = self.feedByTopics[indexPath.section][indexPath.row];

    [cell.image sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"imgLink"]]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    NSString *sectionName = [self.topics[section] objectForKey:@"title"];

    return sectionName;
}

//Uncomment this code for redirect news to browser
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Selected topic URL
    NSString *strUrl = [self.feedByTopics[indexPath.section][indexPath.row] objectForKey:@"link"];
    NSURL *url = [NSURL URLWithString:strUrl];

    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}
*/

//Show news in WebView
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        DetailViewController *controller = (DetailViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
       
        controller.detailItem = [self.feedByTopics[indexPath.section][indexPath.row] objectForKey:@"description"];
    }
}

@end
