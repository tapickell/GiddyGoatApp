//
//  GGCPunchViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/30/12.
//
//

#import "GGCPunchViewController.h"
#import <MapKit/MapKit.h>

@interface GGCPunchViewController ()

@end

@implementation GGCPunchViewController

@synthesize menu;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
