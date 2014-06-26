//
//  HomeViewController.m
//  FeedReader
//
//  Created by IPa Chen on 2014/6/26.
//  Copyright (c) 2014年 A Magic Stuio. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailTableViewController.h"
#import <IPaFeedReader/IPaFeedReader.h>
@interface HomeViewController ()

@end

@implementation HomeViewController
{
    IPaFeedInfo *info;
    NSArray *items;
    NSDateFormatter *formatter;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Parse
    //	NSURL *feedURL = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
    //	NSURL *feedURL = [NSURL URLWithString:@"http://feeds.mashable.com/Mashable"];
    //	NSURL *feedURL = [NSURL URLWithString:@"http://techcrunch.com/feed/"];
    
    NSURL *feedURL = [NSURL URLWithString:@"http://blog.abic.com.tw/?feed=rss2"];
    self.title = @"Loading...";
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:feedURL] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,NSData *data ,NSError *error){
        IPaFeedReader *reader = [[IPaFeedReader alloc] initWithFeedData:data withTextEncoding:NSUTF8StringEncoding];
        [reader parseCompleted:^(IPaFeedInfo* feedInfo,NSArray *feedItems){
            info = feedInfo;
            items = feedItems;
            self.title = info.title;
            [self.tableView reloadData];
        }];
    }];
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"feedCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
	// Configure the cell.
    IPaFeedItem *item = items[indexPath.row];
	if (item) {
		
		// Process
		NSString *itemTitle = item.title;
		NSString *itemSummary = item.summary;
		
		// Set
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		cell.textLabel.text = itemTitle;
		NSMutableString *subtitle = [NSMutableString string];
		if (item.date) [subtitle appendFormat:@"%@: ", [formatter stringFromDate:item.date]];
		[subtitle appendString:itemSummary];
		cell.detailTextLabel.text = subtitle;
		
	}
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Show detail
	IPaFeedItem *item = items[indexPath.row];
    
    [self performSegueWithIdentifier:@"Detail" sender:item];
    
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UIStoryboard
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Detail"]) {
        DetailTableViewController *viewController = segue.destinationViewController;
        viewController.item = sender;
    }
}
@end
