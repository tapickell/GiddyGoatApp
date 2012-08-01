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

@interface GGCPunchViewController : UIViewController < UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AwesomeMenuDelegate>
{
//    UIViewController *mvc1;
//    UIViewController *mvc2;
//    
//    UIPageControl* pageControl;
//    UIScrollView* scrollView;
    UIImagePickerController *imagePicker;
    UIImage *imageSelected;
    //AwesomeMenu *menu;
}

//@property UIViewController *mvc1;
//@property UIViewController *mvc2;

//@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
//@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic)UIImagePickerController *imagePicker;
@property (weak, nonatomic)UIImage *imageSelected;
@property (nonatomic, retain)IBOutlet AwesomeMenu *menu;

- (IBAction)gotoMap:(id)sender;

- (void)getMenuDisplay;

- (void)getViewsForScrolling;

- (IBAction)getPhotoForSharing:(id)sender;

- (IBAction)shareMe:(id)sender;

- (IBAction)callPopup:(id)sender;


@end
