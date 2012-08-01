//
//  GGCPunchViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/30/12.
//
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AwesomeMenu.h"
#import "AwesomeMenuItem.h"

@interface GGCPunchViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AwesomeMenuDelegate>
{
    UIImagePickerController *imagePicker;
    UIImage *imageSelected;
    //AwesomeMenu *menu;
}

@property (weak, nonatomic)UIImagePickerController *imagePicker;
@property (weak, nonatomic)UIImage *imageSelected;
@property (nonatomic, retain)IBOutlet AwesomeMenu *menu;

- (IBAction)gotoMap:(id)sender;

- (void)getMenuDisplay;

- (IBAction)getPhotoForSharing:(id)sender;

- (IBAction)shareMe:(id)sender;

- (IBAction)callPopup:(id)sender;


@end
