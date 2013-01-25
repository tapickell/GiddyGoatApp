/* Copyright (c) 2012, Todd Pickell
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY TODD PICKELL ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL BERND ROSSTAUSCHER BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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

@synthesize punchLabel;
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
    if (passLib) {
        if ([passes count] > 0) {
            PKPass *temp = [passes objectAtIndex:0];
            [punchLabel setText:[temp localizedValueForFieldKey:@"punches"]];
        }
    }

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

- (void)getPassFromServer:(NSMutableString *)urlString
{
    url = [NSURL URLWithString:urlString];
    data = [[NSData alloc] initWithContentsOfURL:url];
    if (data != NULL) {
        updatedPass = [[PKPass alloc] initWithData:data error:nil];
    } else {
        //warning unable to contact server
        NSLog(@"Unable to contact server");
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"Unable to connect to server to update punch card. Please check your network connection and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
    }
}

- (void)getPassesFromLib:(NSNotificationCenter *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //get pass from pass library
        passes = [passLib passes];
        PKPass *temp = [passes objectAtIndex:0];
        [punchLabel setText:[temp localizedValueForFieldKey:@"punches"]];
    });
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
            NSMutableString *newUrlString = [[NSMutableString alloc] initWithString:@"http://toddpickell.me/card/punchMe.php?cp=12"];
            
            dispatch_queue_t newPassQueue = dispatch_queue_create("new pass downloader", NULL);
            dispatch_async(newPassQueue, ^{
                [self getPassFromServer:newUrlString]; //bug fix needed, calls UIAlertView on this thread if fails to get from server!!!FIXED
                //back to main thread for ui 
                dispatch_async(dispatch_get_main_queue(), ^{   
                    if (updatedPass != NULL) {
                        //dispatch_async(dispatch_get_main_queue(), ^{
                            //pop addPassView
                            PKAddPassesViewController *addPassesVC = [[PKAddPassesViewController alloc] initWithPass:updatedPass];
                            [self presentViewController:addPassesVC animated:YES completion:^{}];
                        //});
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"Unable to connect to server to update punch card. Please check your network connection and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }//else UIAlertView failed to retrieve from server or will this never get called
                });//end dispatch get main queue
            });//end new pass queue
        } else {
            //you have our pass let update the punch count for you
            NSLog(@"user has our pass: %@", passes);
            //PKPass *myPass = [passes objectAtIndex:0];
            
            //get Iphone to employee
            UIAlertView *givePhone = [[UIAlertView alloc] initWithTitle:@"Hand iPhone to Barista" message:@"Please hand your iPhone to your Giddy Goat Barista. They will add a punch to your card for you." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [givePhone show];
            //need to get back bool from scanner to update card???
            [self performSegueWithIdentifier:@"segueToScanView" sender:self];
            
            //get updated pass from server
//            NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://mini.local/~toddpickell/punchMe?cn="];
//            [urlString appendString:[myPass serialNumber]];
//            [urlString appendString:@"&cp="];
//            [urlString appendString:[myPass localizedValueForFieldKey:@"punches"]];
            
//            dispatch_queue_t passUpdateQueue = dispatch_queue_create("pass update downloader", NULL);
//            dispatch_async(passUpdateQueue, ^{
//                //[self getPassFromServer:urlString];
//                if (updatedPass != NULL) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        //[passLib replacePassWithPass:updatedPass];
//                    });
//                }
//            });
        }
    } else {
        //sorry you dont have pass library
        NSLog(@"user doesnt have pass library");
    }
    
    
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


- (void)viewDidUnload {
    punchLabel = nil;
    [self setPunchLabel:nil];
    [super viewDidUnload];
}
@end
