//
//  GGCThridViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCThridViewController.h"


@implementation GGCThridViewController


- (void)viewWillAppear:(BOOL)animated
{
    UIDevice *device = [UIDevice currentDevice];
    
    if ([[device model] isEqualToString:@"iPhone"] ) {
        NSLog(@"Your device is an iPhone.");
    } else {
        NSLog(@"Your device doesn't support this feature.");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.    
}

- (void)viewDidUnload
{
        //[self setTableView:nil];
    callButton = nil;
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

- (IBAction)callPopup:(id)sender 
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        NSLog(@"Calling Giddy Goat Coffee House");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://5734266750"]]];
    } else {
        NSLog(@"Your device doesn't support this feature.");
    }
}


@end
