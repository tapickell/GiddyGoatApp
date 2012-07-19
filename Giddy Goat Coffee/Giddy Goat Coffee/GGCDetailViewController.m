//
//  GGCDetailViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCDetailViewController.h"
#import <Twitter/Twitter.h>

@interface GGCDetailViewController ()

@end

@implementation GGCDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    itemNameLabel = nil;
    itemDescripLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)backgroundTapped:(id)sender {
    NSLog(@"Background tapped");
        //[[self parentViewController] dismissModalViewControllerAnimated:YES];
        //[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)shareMe:(id)sender
{
    NSString *textToShare = @"@TGGCHRolla ";
    UIImage *imageToShare = [UIImage imageNamed:@"GiddyScreenShot.png"];
    NSArray *activityItems = @[textToShare, imageToShare];
    
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        if ([TWTweetComposeViewController canSendTweet])
        {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:textToShare];
            [self presentModalViewController:tweetSheet animated:YES];
        }
    } else {
            //code for ios 6
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        [self presentViewController:activityVC animated:YES completion:nil];
    }    
}

@end
