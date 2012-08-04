//
//  GGCPunchViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/30/12.
//
//

#import "GGCPunchViewController.h"
#import "IIViewDeckController.h"
#import <Twitter/Twitter.h>
#import <MapKit/MapKit.h>


@interface GGCPunchViewController ()

@end

@implementation GGCPunchViewController

@synthesize imagePicker = _imagePicker;
@synthesize imageSelected = _imageSelected;
@synthesize menu;
@synthesize passLib = _passLib;
@synthesize passes = _passes;

#define CAMERA @"Camera"
#define LIBRARY @"Photo Library"


#pragma mark - view methods

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
    NSLog(@"punch view did load");
    [self getMenuDisplay];
    passLib = [[PKPassLibrary alloc] init];
    passes = [passLib passes];
    noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter addObserver:self selector:@selector(getPassesFromLib:) name:PKPassLibraryDidChangeNotification object:passLib];
    
}

- (void)didReceiveMemoryWarning
{
    [TestFlight passCheckpoint:@"Did Recieve Memory Warning!!!"];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - passbook integration

- (PKPass *)getPassFromServer:(NSMutableString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    PKPass *updatedPass = [[PKPass alloc] initWithData:data error:nil];
    return updatedPass;
}

- (void)getPassesFromLib:(NSNotificationCenter *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //get pass from pass library
        passes = [passLib passes];
    });
}

#pragma mark - awesome menu display methods

- (void)getMenuDisplay
{
	// Do any additional setup after loading the view.
    NSString *itemBack = @"bg-menuitem.png";
    
    //create menu items
    AwesomeMenuItem *menuItem0 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"arrow-west.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"map-marker.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"bubbleIcon.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"group.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem4 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"phone.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem5 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"arrow-east.png"] highlightedContentImage:nil];
    
    //add menu items to array
    NSArray *menus = [NSArray arrayWithObjects:menuItem0, menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, nil];
    
    //create menu
    menu = [[AwesomeMenu alloc] initWithFrame:self.view.window.bounds menus:menus];
    
    //configure menu options
    menu.startPoint = CGPointMake(160.0, 435.0);
    menu.menuWholeAngle = M_PI;
    menu.rotateAngle = -1.3;
    menu.nearRadius = 60.0f;
    menu.endRadius = 90.0f;
    menu.farRadius = 130.0f;
    menu.delegate = self;
    
    //add menu to view
    [self.view addSubview:menu];
}

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    //NSLog(@"Select the index : %d",idx);
    //switch to call methods when menu items are selected
    switch (idx) {
        case 0:
            //reveal left view
            [self.viewDeckController toggleLeftViewAnimated:YES];
            [TestFlight passCheckpoint:@"Menu Nav to Specials View"];
            break;
            
        case 1:
            //go to maps
            [self gotoMap:self];
            break;
            
        case 2:
            //go to social
            [self getPhotoForSharing:self];
            break;
        case 3:
            //got to credits
            [self performSegueWithIdentifier:@"segueToCredits" sender:self];
            break;
            
        case 4:
            //call giddy
            [self callPopup:self];
            break;
            
        case 5:
            //reveal right view
            [self.viewDeckController toggleRightViewAnimated:YES];
            [TestFlight passCheckpoint:@"Menu Nav to Coffees View"];
            break;
            
        default:
            break;
    }
}


#pragma mark - Maps Integration for iOS5 and iOS6


- (IBAction)gotoMap:(id)sender
{
    //get ios version
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    
    //if ios5 or lower use google maps
    if (versionNumber < 6) {
        [TestFlight passCheckpoint:@"USING_GOOGLE_MAPS_IOS5"];
        NSURL *mapUrl = [[NSURL alloc] initWithString:@"http://maps.google.com/maps?q=704+n+bishop+Ave+suite+2+rolla+mo+65401&ll=37.949807,-91.776859"];
        [[UIApplication sharedApplication] openURL:mapUrl];
        mapUrl = nil;
    } else {
        //if ios6 use apple maps
        ////NSLog(@"opening maps app in iOS 6");
        [TestFlight passCheckpoint:@"USING_APPLE_MAPS_IOS6"];
        
        //new code using mkmapitem & mkplacemark
        MKPlacemark *giddyPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.949807,-91.776859) addressDictionary:nil];
        MKMapItem *giddyLocation = [[MKMapItem alloc] initWithPlacemark:giddyPlacemark];
        
        //add extra features to display in map app
        giddyLocation.name = @"Giddy Goat Coffee";
        giddyLocation.phoneNumber = @"+15734266750";
        giddyLocation.url = [NSURL URLWithString:@"http://tggch.com"];
        
        //open in iOS6 maps app
        [giddyLocation openInMapsWithLaunchOptions:nil];
    }
}

#pragma mark - Social Integration / Photo Upload

- (IBAction)getPhotoForSharing:(id)sender
{
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //add button for camera
        [actionSheet addButtonWithTitle:CAMERA];
    }
    //if photo library is available add that to the popup list of options
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        //add button for library
        [actionSheet addButtonWithTitle:LIBRARY];
    }
    //show action sheet
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *desired = (NSString *)kUTTypeImage;
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == [actionSheet cancelButtonIndex])
    {
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

    [self presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //extract image
    imageSelected = [info objectForKey:UIImagePickerControllerEditedImage];
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
    
    //add items to array
    if (imageSelected)
    {
        //if there is an image to be passed
        activityItems = @[textToShare, imageSelected];
    } else {
        //no image
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
}

#pragma mark - call features

- (IBAction)callPopup:(id)sender
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] )
    {
        //NSLog(@"Calling Giddy Goat Coffee House");
        [TestFlight passCheckpoint:@"USING_CALL_FEATURE"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://5734266750"]]];
    } else {
        //NSLog(@"Your device doesn't support this feature.");
    }
}



- (IBAction)getCardPunch:(id)sender
{
    [TestFlight passCheckpoint:@"USING_PUNCH_CARD_FEATURE"];
    //method to add punch to punch card
    
    if (passLib) {
        //you have pass library
        NSLog(@"user has pass library");
        if ([passes count] == 0) {
            //you dont have our pass yet, lets get you a new one, shall we.
            NSLog(@"user doesnt have our pass");
            NSMutableString *newUrlString = [[NSMutableString alloc] initWithString:@"http://mini.local/~toddpickell/punchMe?cp=12"];
            PKPass *newPass = [self getPassFromServer:newUrlString];
            //pop addPassView
            PKAddPassesViewController *addPassesVC = [[PKAddPassesViewController alloc] initWithPass:newPass];
            [self presentViewController:addPassesVC animated:YES completion:^{}];
            
        } else {
            //you have our pass let update the punch count for you
            NSLog(@"user has our pass: %@", passes);
            PKPass *myPass = [passes objectAtIndex:0];
            
            //get updated pass from server
            NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://mini.local/~toddpickell/punchMe?cn="];
            [urlString appendString:[myPass serialNumber]];
            [urlString appendString:@"&cp="];
            [urlString appendString:[myPass localizedValueForFieldKey:@"punches"]];
            PKPass *updatedPass;
            updatedPass = [self getPassFromServer:urlString];

            [passLib replacePassWithPass:updatedPass];
        }
    } else {
        //sorry you dont have pass library
        NSLog(@"user doesnt have pass library");
    }
    
    
}









@end
