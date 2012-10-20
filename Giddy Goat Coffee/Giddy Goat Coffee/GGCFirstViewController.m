/* Copyright (c) 2012, Todd Pickell
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY TODD PICKELL ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL BERND ROSSTAUSCHER BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  GGCFirstViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCFirstViewController.h"
#import "IIViewDeckController.h"


@implementation GGCFirstViewController

@synthesize updateArray;
@synthesize specialsLabel;


- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self getMenuDisplay];
    NSLog(@"first view did load");
    
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
    //dispatch_release(downloadQueue);
}

- (void)viewDidUnload
{
    [self setSpecialsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - status update and cache methods

- (void)getStatusData
{
    NSString *arrayPath;
    arrayPath = [self statusArrayFilePath];
    NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
    if (arrayFromFile) {
        //NSLog(@"ArrayFromFile: [0]:%@ [1]:%@", [arrayFromFile objectAtIndex:0], [arrayFromFile objectAtIndex:1]);
        NSInteger months;
        NSInteger days;
        [self compareDates:arrayFromFile months_p:&months days_p:&days];
            
            ////NSLog(@"Months: %d Days: %d", months, days);
        
        if (days > 0 || months > 0) {
                //get fresh feed
                //NSLog(@"Getting fresh data");
            [self fetchSpecials];
        } else {
                //NSLog(@"Loading cache data");
            updateArray = [[NSMutableArray alloc] initWithContentsOfFile:[self statusArrayFilePath]];
            [TestFlight passCheckpoint:@"Loading cached twitFeed"];
                ////NSLog(@"Update Array: %@", updateArray);
        }
    } else {
            //if no file on file system yet get fresh feed
            [self fetchSpecials];
    }
}

- (void)fetchSpecials
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=giddygoatupdate&count=1"];
    [TestFlight passCheckpoint:@"Getting fresh twitFeed"];
    updateArray = [[NSMutableArray alloc] init];
    
        //try to use just strings instead of mutableStrings with append
    NSString *updateString = [[NSMutableString alloc] init];
    NSString *dateString = [[NSMutableString alloc] init];
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfURL:url];
        //convert xml to string and dump to log
        //NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        ////NSLog(@"xmlCheck:\n%@", xmlCheck);
    
    if (xmlData) {
            //tbxml = [[TBXML alloc] initWithXMLData:xmlData];
        tbxml = [[TBXML alloc] initWithURL:url];
        
            //obtain root element
        TBXMLElement * root = tbxml.rootXMLElement;
        if (root) {
                ////NSLog(@"Got Root Element");
            TBXMLElement * elem_status = [TBXML childElementNamed:@"status" parentElement:root];
            while (elem_status != nil) {
                    ////NSLog(@"elem_status != nil");
                
                TBXMLElement * elem_date = [TBXML childElementNamed:@"created_at" parentElement:elem_status];
                dateString = [dateString stringByAppendingString:[TBXML textForElement:elem_date]];
                
                TBXMLElement * elem_text = [TBXML childElementNamed:@"text" parentElement:elem_status];
                updateString = [updateString stringByAppendingString:[TBXML textForElement:elem_text]];
                
                elem_status = [TBXML nextSiblingNamed:@"status" searchFromElement:elem_status];
            }
        }
    } else {
        [TestFlight passCheckpoint:@"TWITTER_FEED_WAS_DOWN!!!"];
            //just in case feed is down *July 6, 2012 2:23:59* 
        dateString = [dateString stringByAppendingString:@"2012-07-06 14:23:59 +0000"];
        updateString = [updateString stringByAppendingString:@"No specials listed today. Please check back later."];
    }
    [updateArray addObject:dateString];
    [updateArray addObject:updateString];
        ////NSLog(@"Saving XML to file system");
    [updateArray writeToFile:[self statusArrayFilePath] atomically:YES];
    url = nil;
}

- (void)compareDates:(NSArray *)arrayFromFile months_p:(NSInteger *)months_p days_p:(NSInteger *)days_p
{
        //select date format for string in
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
        //get date from array
    NSDate *dateFromFile = [dateFormatter dateFromString:[arrayFromFile objectAtIndex:0]];
        //NSLog(@"File Date:    %@", dateFromFile);
    NSDate *now = [NSDate date];
        //NSLog(@"Current Date: %@", now);
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
        //NSLog(@"Manual; Months: %d Days: %d", monthComp, dayComp);
    
    
        //NSDateComponents *comp = [cal components:units fromDate:now toDate:dateFromFile options:0];
        //save comparison as nsinteger
        ////NSLog(@"Months: %d Days: %d", [comp month], [comp day]);
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


- (IBAction)backToCenter:(id)sender
{
    [self.viewDeckController toggleLeftViewAnimated:YES];
    [TestFlight passCheckpoint:@"Button nav from specials view"];
}
@end
