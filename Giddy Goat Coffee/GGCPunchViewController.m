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
#define ACTIONSHEET_TITLE @"YOUR GIDDY PUNCH CARD IS FULL!!!              Congrats on filling the punches on your Giddy Goat card. Please hand your iPhone to the Barista and they will give you the discount."


#pragma mark - view methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    number_of_punches = [self getPunchesFromLocalStorage];
    [self updatePunchLabel];

    [self getMenuDisplay];

}

- (void)viewDidAppear:(BOOL)animated
{
    number_of_punches = [self getPunchesFromLocalStorage];
    [self updatePunchLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - passbook bypass

- (NSInteger)getPunchesFromLocalStorage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger not_using_passbook = [defaults integerForKey:@"not_using_passbook"];
    if (not_using_passbook == 0) {
        NSInteger count = [self punchesFromPKPass];
        [defaults setInteger:1 forKey:@"not_using_passbook"];
        [defaults setInteger:count forKey:@"punches"];
    }
    return [defaults integerForKey:@"punches"];
}

- (void)savePunchesToLocalStorage:(NSInteger)punches
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:punches forKey:@"punches"];
}

- (NSInteger)punchesFromPKPass
{
    NSInteger returnValue = 0;
    passLib = [[PKPassLibrary alloc] init];
    passes = [passLib passes];
    if (passLib) {
        if ([passes count] > 0) {
            PKPass *temp = [passes objectAtIndex:0];
            returnValue = [[temp localizedValueForFieldKey:@"punches"] integerValue];
        }
    }
    return returnValue;
}

- (void)updatePunchLabel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [punchLabel setText:[NSString stringWithFormat:@"%d", number_of_punches]];
    });
}

- (void)displayFullPunchCardSheet
{
    //card is full display custom alert for 10 punch rule
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ACTIONSHEET_TITLE
                                                             delegate:self
                                                    cancelButtonTitle:@"Get The Discount"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    UIImageView *picView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red-and-star.png"]];
    [actionSheet addSubview:picView];
    [actionSheet sendSubviewToBack:picView];
    [actionSheet showInView:self.view];
    NSLog(@"Cancel Button Pressed");
}

- (void)displayReadyToPunchAlert
{
    UIAlertView *givePhone = [[UIAlertView alloc] initWithTitle:@"Hand iPhone to Barista" message:@"Please hand your iPhone to your Giddy Goat Barista. They will add a punch to your card for you." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [givePhone show];
}

- (IBAction)getCardPunch:(id)sender
{
    if (number_of_punches == 10) {
        [self displayFullPunchCardSheet];
    } else {
        [self displayReadyToPunchAlert];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex])
    {
        [self openScanView];
    }
}

- (void)openScanView
{
    [self performSegueWithIdentifier:@"segueToScanView" sender:self];
}

#pragma mark - passbook integration

- (void)getPassFromServer:(NSMutableString *)urlString
{
    url = [NSURL URLWithString:urlString];
    data = [[NSData alloc] initWithContentsOfURL:url];
    if (data != NULL) {
        updatedPass = [[PKPass alloc] initWithData:data error:nil];
    }
}

- (void)getPassesFromLib:(NSNotificationCenter *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        passes = [passLib passes];
        PKPass *temp = [passes objectAtIndex:0];
        [punchLabel setText:[temp localizedValueForFieldKey:@"punches"]];
    });
}

- (IBAction)getCardPunchOld:(id)sender
{
    if (passLib) {
        if ([passes count] == 0) {
        } else {
            if ([punchLabel.text isEqual: @"10"]) {
                [self displayFullPunchCardSheet];
            } else {
                [self displayReadyToPunchAlert];
            }
            [self performSegueWithIdentifier:@"segueToScanView" sender:self];
        }
    }
}



#pragma mark - awesome menu display methods

- (void)getMenuDisplay
{
    NSString *itemBack = @"bg-menuitem.png";
    AwesomeMenuItem *menuItem0 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"arrow-west.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"map-marker.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"bubbleIcon.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"group.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem4 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"phone.png"] highlightedContentImage:nil];
    AwesomeMenuItem *menuItem5 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:itemBack] highlightedImage:nil ContentImage:[UIImage imageNamed:@"arrow-east.png"] highlightedContentImage:nil];

    NSArray *menus = [NSArray arrayWithObjects:menuItem0, menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, nil];
    menu = [[AwesomeMenu alloc] initWithFrame:self.view.window.bounds menus:menus];
    menu.startPoint = CGPointMake(160.0, 485.0);
    menu.menuWholeAngle = M_PI;
    menu.rotateAngle = -1.3;
    menu.nearRadius = 60.0f;
    menu.endRadius = 90.0f;
    menu.farRadius = 130.0f;
    menu.delegate = self;
    [self.view addSubview:menu];
}

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    switch (idx) {
        case 0:
            [self.viewDeckController toggleLeftViewAnimated:YES];
            break;

        case 1:
            [self gotoMap:self];
            break;

        case 2:
            [self getPhotoForSharing:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"segueToCredits" sender:self];
            break;

        case 4:
            [self callPopup:self];
            break;

        case 5:
            [self.viewDeckController toggleRightViewAnimated:YES];
            break;

        default:
            break;
    }
}


#pragma mark - Maps Integration for iOS5 and iOS6


- (IBAction)gotoMap:(id)sender
{
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        NSURL *mapUrl = [[NSURL alloc] initWithString:@"http://maps.google.com/maps?q=704+n+bishop+Ave+suite+2+rolla+mo+65401&ll=37.949807,-91.776859"];
        [[UIApplication sharedApplication] openURL:mapUrl];
        mapUrl = nil;
    } else {
        MKPlacemark *giddyPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.949807,-91.776859) addressDictionary:nil];
        MKMapItem *giddyLocation = [[MKMapItem alloc] initWithPlacemark:giddyPlacemark];
        giddyLocation.name = @"Giddy Goat Coffee";
        giddyLocation.phoneNumber = @"+15734266750";
        giddyLocation.url = [NSURL URLWithString:@"http://tggch.com"];
        [giddyLocation openInMapsWithLaunchOptions:nil];
    }
}

#pragma mark - Social Integration / Photo Upload

- (IBAction)getPhotoForSharing:(id)sender
{
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Send With Photo"
                                                             delegate:self
                                                    cancelButtonTitle:@"No Photo"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [actionSheet addButtonWithTitle:CAMERA];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        [actionSheet addButtonWithTitle:LIBRARY];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title  isEqual: ACTIONSHEET_TITLE]) {
        if (buttonIndex == [actionSheet cancelButtonIndex])
        {
            [self openScanView];
        }
    } else {
        NSString *desired = (NSString *)kUTTypeImage;
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if (buttonIndex == [actionSheet cancelButtonIndex])
        {
            imageSelected = nil;
            [self shareMe:self];
            return;
        } else if ([choice isEqualToString:CAMERA]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if ([choice isEqualToString:LIBRARY]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }

        imagePicker.allowsEditing = YES;
        imagePicker.mediaTypes = [NSArray arrayWithObject:desired];

        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageSelected = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{[self shareMe:self];}];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];;
}

- (IBAction)shareMe:(id)sender
{
    NSString *textToShare = @"@TGGCHRolla ";
    NSArray *activityItems;
    if (imageSelected)
    {
        activityItems = @[textToShare, imageSelected];
    } else {
        activityItems = @[textToShare];
    }

    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
    } else {
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://5734266750"]]];
    } else {
    }
}


- (void)viewDidUnload {
    punchLabel = nil;
    [self setPunchLabel:nil];
    [super viewDidUnload];
}
@end
