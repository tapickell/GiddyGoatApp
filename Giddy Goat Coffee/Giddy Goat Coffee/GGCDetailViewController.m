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
        //NSLog(@"Background tapped");
        //[[self parentViewController] dismissModalViewControllerAnimated:YES];
        //[[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
    [self dismissModalViewControllerAnimated:YES];
}

@end
