//
//  GGCFirstViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TBXML.h"
#import "AwesomeMenu/AwesomeMenu.h"
#import "AwesomeMenu/AwesomeMenuItem.h"

@interface GGCFirstViewController : UIViewController <UINavigationControllerDelegate>
{
    NSMutableArray *updateArray;
    TBXML *tbxml;
}

- (IBAction)backToCenter:(id)sender;

@property (nonatomic)NSMutableArray *updateArray;
@property (weak, nonatomic) IBOutlet UILabel *specialsLabel;

- (void)getStatusData;
- (void)fetchSpecials;
- (NSString *)statusArrayFilePath;

- (void)compareDates:(NSArray *)arrayFromFile months_p:(NSInteger *)months_p days_p:(NSInteger *)days_p;

@end
