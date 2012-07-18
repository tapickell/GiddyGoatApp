//
//  GGCFirstViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCFirstViewController.h"


@interface GGCFirstViewController ()

@end

@implementation GGCFirstViewController

@synthesize updateArray;
@synthesize specialsLabel;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        //get downloads on async thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("status downloader", NULL);
    dispatch_async(downloadQueue, ^{
            //get daily specials from @giddygoatupdate
        [self getStatusData];
        dispatch_async(dispatch_get_main_queue(), ^{
                //update label with daily specials from feed
                [specialsLabel setText:[updateArray objectAtIndex:1]];
        });
    });
    dispatch_release(downloadQueue);
}

- (void)viewDidUnload
{
    [self setSpecialsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - FirstView Links

- (IBAction)gotoMap:(id)sender {
    NSMutableString *url = [[NSMutableString alloc] init];
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        [url appendString:@"http://maps.google.com/maps?q=704+n+bishop+Ave+suite+2+rolla+mo+65401&ll=37.949807,-91.776859"];
    } else {
            //code for ios 6 map integration
        NSLog(@"opening maps app in iOS 6");
        [url appendString:@"http://maps.apple.com/maps?q=704+n+bishop+Ave+suite+2+rolla+mo+65401"];
    }
    NSURL *mapUrl = [[NSURL alloc] initWithString:url];
    [[UIApplication sharedApplication] openURL:mapUrl];
}

- (IBAction)gotoFB:(id)sender {
    NSString *url = @"https://www.facebook.com/pages/The-Giddy-Goat-Coffeehouse/81265198875";
    NSURL *fburl = [[NSURL alloc] initWithString:url];
    [[UIApplication sharedApplication] openURL:fburl];
}

- (IBAction)gotoTwitter:(id)sender {
    NSString *url = @"http://twitter.com/TGGCHRolla";
    NSURL *tweetUrl = [[NSURL alloc] initWithString:url];
    [[UIApplication sharedApplication] openURL:tweetUrl];
}

#pragma mark - status update and cache methods

- (void)getStatusData
{
    NSString *arrayPath;
    arrayPath = [self statusArrayFilePath];
    NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
    if (arrayFromFile) {
        NSInteger months;
        NSInteger days;
        [self compareDates:arrayFromFile months_p:&months days_p:&days];
            
        NSLog(@"Months: %d Days: %d", months, days);
        
        if (days > 0 || months > 0) {
                //get fresh feed
            NSLog(@"Getting fresh data");
            [self fetchSpecials];
        } else {
            NSLog(@"Loading cache data");
            updateArray = [[NSMutableArray alloc] initWithContentsOfFile:[self statusArrayFilePath]];
            NSLog(@"Update Array: %@", updateArray);
        }
    } else {
            //if no file on file system yet get fresh feed
            [self fetchSpecials];
    }
}

- (void)fetchSpecials
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=giddygoatupdate&count=1"];
    
    updateArray = [[NSMutableArray alloc] init];
    
    NSMutableString *updateString = [[NSMutableString alloc] init];
    NSMutableString *dateString = [[NSMutableString alloc] init];
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfURL:url];
        //convert xml to string and dump to log
        //NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        //NSLog(@"xmlCheck:\n%@", xmlCheck);
    
    if (xmlData) {
            //tbxml = [[TBXML alloc] initWithXMLData:xmlData];
        tbxml = [[TBXML alloc] initWithURL:url];
        
            //obtain root element
        TBXMLElement * root = tbxml.rootXMLElement;
        if (root) {
            NSLog(@"Got Root Element");
            TBXMLElement * elem_status = [TBXML childElementNamed:@"status" parentElement:root];
            while (elem_status != nil) {
                NSLog(@"elem_status != nil");
                
                TBXMLElement * elem_date = [TBXML childElementNamed:@"created_at" parentElement:elem_status];
                NSString *date = [TBXML textForElement:elem_date];
                NSLog(@"Status Date:  %@", date);
                [dateString appendString:date];
                
                TBXMLElement * elem_text = [TBXML childElementNamed:@"text" parentElement:elem_status];
                NSString *text = [TBXML textForElement:elem_text];
                NSLog(@"Status: %@", text);
                [updateString appendString:text];
                
                elem_status = [TBXML nextSiblingNamed:@"status" searchFromElement:elem_status];
            }
        }
    } else {
            //just in case feed is down
        [dateString appendString:@"2012-01-01 00:00:00 +0000"];
        [updateString appendString:@"No specials listed today. Please check back later."];
    }
    [updateArray addObject:dateString];
    [updateArray addObject:updateString];
    NSLog(@"Saving XML to file system");
    [updateArray writeToFile:[self statusArrayFilePath] atomically:YES];
}

- (void)compareDates:(NSArray *)arrayFromFile months_p:(NSInteger *)months_p days_p:(NSInteger *)days_p
{
        //select date format for string in
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
        //get date from array
    NSDate *dateFromFile = [dateFormatter dateFromString:[arrayFromFile objectAtIndex:0]];
        NSLog(@"File Date:    %@", dateFromFile);
    NSDate *now = [NSDate date];
        NSLog(@"Current Date: %@", now);
        //convert dates to days and months for comparison
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger units = NSMonthCalendarUnit | NSDayCalendarUnit;
        //compare months and days
        //NSDateComponents *comp = [cal components:units fromDate:dateFromFile toDate:now options:0];
    
        //trying manual comparison since this comp failed to see 1 day difference in dates maybe due to times???
    NSDateComponents *nowComps = [cal components:units fromDate:now];
    NSDateComponents *fileComps = [cal components:units fromDate:dateFromFile];
    NSInteger dayComp = [nowComps day] - [fileComps day];
    NSInteger monthComp = [nowComps month] - [fileComps month];
    NSLog(@"Manual; Months: %d Days: %d", monthComp, dayComp);
    
    
        //NSDateComponents *comp = [cal components:units fromDate:now toDate:dateFromFile options:0];
        //save comparison as nsinteger
        //NSLog(@"Months: %d Days: %d", [comp month], [comp day]);
    *months_p = monthComp;
    *days_p = dayComp;
    
    
}

- (NSString *)statusArrayFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
        // Path to save array data
    NSString  *arrayPath = [[paths objectAtIndex:0]
                            stringByAppendingPathComponent:@"status.out"];
    return arrayPath;
}



@end
