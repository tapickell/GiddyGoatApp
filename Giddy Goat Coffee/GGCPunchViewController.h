//
//  GGCPunchViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/30/12.
//
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <PassKit/PassKit.h>
#import "AwesomeMenu.h"
#import "AwesomeMenuItem.h"


@interface GGCPunchViewController : UIViewController < UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AwesomeMenuDelegate>
{
    UIImagePickerController *imagePicker;
    UIImage *imageSelected;
    PKPassLibrary *passLib;
    NSArray *passes;
    NSNotificationCenter *noteCenter;
    NSURL *url;
    NSData *data;
    PKPass *updatedPass;

}

- (IBAction)getCardPunch:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *punchLabel;

@property (weak, nonatomic)UIImagePickerController *imagePicker;
@property (weak, nonatomic)UIImage *imageSelected;
@property (nonatomic, retain)IBOutlet AwesomeMenu *menu;
@property (weak, nonatomic)PKPassLibrary *passLib;
@property (weak, nonatomic)NSArray *passes;


- (IBAction)gotoMap:(id)sender;

- (void)getMenuDisplay;

- (void)getPassesFromLib:(NSNotificationCenter *)notification;

- (void)getPassFromServer:(NSMutableString *)urlString;

- (IBAction)getPhotoForSharing:(id)sender;

- (IBAction)shareMe:(id)sender;

- (IBAction)callPopup:(id)sender;


@end
