//
//  GGCDetailViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGCDetailViewController : UIViewController
{
   __weak IBOutlet UILabel *itemNameLabel;
   __weak IBOutlet UILabel *itemDescripLabel;
   
}

- (IBAction)backgroundTapped:(id)sender;

@end
