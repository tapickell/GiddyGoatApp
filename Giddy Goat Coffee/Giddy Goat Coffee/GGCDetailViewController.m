//
//  GGCDetailViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCDetailViewController.h"


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
    NSLog(@"detail view did load");
	// Do any additional setup after loading the view.
    [TestFlight passCheckpoint:@"VIEWING_CREDITS_PAGE"];
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
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)backgroundTapped:(id)sender {
        //NSLog(@"Background tapped");
    [self dismissModalViewControllerAnimated:YES];
}

@end
