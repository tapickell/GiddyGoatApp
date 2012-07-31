//
//  GGCPunchViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/30/12.
//
//

#import "GGCPunchViewController.h"
#import <Twitter/Twitter.h>
#import <MapKit/MapKit.h>

@interface GGCPunchViewController ()

@end

@implementation GGCPunchViewController

@synthesize imagePicker = _imagePicker;
@synthesize imageSelected = _imageSelected;
@synthesize menu;

#define CAMERA @"Camera"
#define LIBRARY @"Photo Library"

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
    [self getMenuDisplay];
}

#pragma mark - awesome menu display methods

- (void)getMenuDisplay
{
	// Do any additional setup after loading the view.
    AwesomeMenuItem *menuItem1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"map-marker.png"] highlightedImage:nil ContentImage:nil highlightedContentImage:nil];
    AwesomeMenuItem *menuItem2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bubbleIcon.png"] highlightedImage:nil ContentImage:nil highlightedContentImage:nil];
    AwesomeMenuItem *menuItem3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"pricetag.png"] highlightedImage:nil ContentImage:nil highlightedContentImage:nil];
    AwesomeMenuItem *menuItem4 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"coffeeCup.png"] highlightedImage:nil ContentImage:nil highlightedContentImage:nil];
    AwesomeMenuItem *menuItem5 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"group.png"] highlightedImage:nil ContentImage:nil highlightedContentImage:nil];
    AwesomeMenuItem *menuItem6 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"phone.png"] highlightedImage:nil ContentImage:nil highlightedContentImage:nil];
    NSArray *menus = [NSArray arrayWithObjects:menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, menuItem6,  nil];
    
    
    menu = [[AwesomeMenu alloc] initWithFrame:self.view.window.bounds menus:menus];
    menu.startPoint = CGPointMake(160.0, 430.0);
    menu.menuWholeAngle = M_PI / 1.1;
    menu.rotateAngle = -1.18;
    menu.nearRadius = 80.0f;
    menu.endRadius = 100.0f;
    menu.farRadius = 120.0f;
    menu.delegate = self;
    [self.view addSubview:menu];
}

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"Select the index : %d",idx);
    switch (idx) {
        case 0:
            //go to maps
            [self gotoMap:self];
            break;
        case 1:
            //go to social
            [self getPhotoForSharing:self];
            break;
        case 2:
            //got to specials
            break;
        case 3:
            //go to cofffees
            break;
        case 4:
            //go to credits
            break;
        case 5:
            //call giddy
            break;
            
        default:
            break;
    }
}

#pragma mark - Maps Integration for iOS5 and iOS6

- (IBAction)gotoMap:(id)sender {
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        [TestFlight passCheckpoint:@"USING_GOOGLE_MAPS_IOS5"];
        NSURL *mapUrl = [[NSURL alloc] initWithString:@"http://maps.google.com/maps?q=704+n+bishop+Ave+suite+2+rolla+mo+65401&ll=37.949807,-91.776859"];
        [[UIApplication sharedApplication] openURL:mapUrl];
        mapUrl = nil;
    } else {
        //code for ios 6 map integration
        ////NSLog(@"opening maps app in iOS 6");
        [TestFlight passCheckpoint:@"USING_APPLE_MAPS_IOS6"];
        //new code using mkmapitem & mkplacemark
        MKPlacemark *giddyPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.949807,-91.776859) addressDictionary:nil];
        MKMapItem *giddyLocation = [[MKMapItem alloc] initWithPlacemark:giddyPlacemark];
        //add extra features to display in map app
        giddyLocation.name = @"Giddy Goat Coffee";
        giddyLocation.phoneNumber = @"+15734266750";
        giddyLocation.url = [NSURL URLWithString:@"http://tggch.com"];
        
        //open in iOS6 maps
        [giddyLocation openInMapsWithLaunchOptions:nil];
    }
}

#pragma mark - Social Integration / Photo Upload

- (IBAction)getPhotoForSharing:(id)sender {
    //create image picker controller
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    //create action sheet to prompt user with options for pictures
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Send With Photo"
                                                             delegate:self
                                                    cancelButtonTitle:@"No Photo"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    //set action sheet style
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    //if camera is available add that to the popup list of options
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //add button for camera
        [actionSheet addButtonWithTitle:CAMERA];
    }
    //if photo library is available add that to the popup list of options
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //add button for library
        [actionSheet addButtonWithTitle:LIBRARY];
    }
    //show action sheet
    //issues with displaying
    //[actionSheet showInView:self.parentViewController.view];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *desired = (NSString *)kUTTypeImage;
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        //No Photos jump to shareMe
        [TestFlight passCheckpoint:@"NOT_SHARING_PHOTO"];
        imageSelected = nil;
        //imageURL = nil;
        [self shareMe:self];
        return;
    } else if ([choice isEqualToString:CAMERA]) {
        //get photo from camera
        [TestFlight passCheckpoint:@"TAKING_PIC_TO_SHARE"];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([choice isEqualToString:LIBRARY]) {
        //get photo from library
        [TestFlight passCheckpoint:@"GETTING_PIC_FROM_LIBRARY"];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = [NSArray arrayWithObject:desired];
    //issues on new view
    //[self.parentViewController presentModalViewController:imagePicker animated:YES];
    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //extract image
    imageSelected = [info objectForKey:UIImagePickerControllerEditedImage];
    //imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    //NSLog(@"imageSelected url: %@",imageURL);
    
    //[self dismissViewControllerAnimated:YES completion:^([self shareMe:self])];
    [self dismissViewControllerAnimated:YES completion:^{[self shareMe:self];}];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];;
}

- (IBAction)shareMe:(id)sender
{
    [TestFlight passCheckpoint:@"USING_SOCIAL_FEATURES"];
    NSString *textToShare = @"@TGGCHRolla ";
    NSArray *activityItems;
    if (imageSelected) {
        //NSLog(@"Image Selected: %@", imageSelected);
        
        activityItems = @[textToShare, imageSelected];
    } else {
        activityItems = @[textToShare];
    }
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        if ([TWTweetComposeViewController canSendTweet])
        {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:textToShare];
            if (imageSelected) {
                [tweetSheet addImage:imageSelected];
            }
            [self presentModalViewController:tweetSheet animated:YES];
        }
    } else {
        //code for ios 6
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    imageSelected = nil;
    //imageURL = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
