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

@interface GGCFirstViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AwesomeMenuDelegate>
{
    NSMutableArray *updateArray;
    TBXML *tbxml;
    UIImagePickerController *imagePicker;
    UIImage *imageSelected;
    NSURL *imageURL;
}

@property (nonatomic)NSMutableArray *updateArray;
@property (weak, nonatomic) IBOutlet UILabel *specialsLabel;
@property (weak, nonatomic)UIImagePickerController *imagePicker;
@property (weak, nonatomic)UIImage *imageSelected;
@property (weak, nonatomic)NSURL *imageUrl;

@property (nonatomic, retain)IBOutlet AwesomeMenu *menu;

- (void)getMenuDisplay;

- (IBAction)gotoMap:(id)sender;

- (IBAction)getPhotoForSharing:(id)sender;

- (IBAction)shareMe:(id)sender;

- (void)getStatusData;
- (void)fetchSpecials;
- (NSString *)statusArrayFilePath;

- (void)compareDates:(NSArray *)arrayFromFile months_p:(NSInteger *)months_p days_p:(NSInteger *)days_p;

@end
