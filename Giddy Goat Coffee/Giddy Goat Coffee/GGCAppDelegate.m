//
//  GGCAppDelegate.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCAppDelegate.h"

#import "IIViewDeckController.h"
#import "GGCPunchViewController.h"
#import "GGCFirstViewController.h"
#import "GGCSecondViewController.h"


@implementation GGCAppDelegate

@synthesize window = _window;
@synthesize punchVC = _punchVC;
@synthesize firstVC = _firstVC;
@synthesize secondVC = _secondVC;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"4b4e8a904763818917de01b7c76985f2_OTg3MzcyMDEyLTA2LTEwIDE5OjQ0OjQ2LjAyNTkxMg"];
    
    //stuff for viewDeck
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    NSLog(@"alloc window");
    
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"NewStoryboard" bundle:nil];
    NSLog(@"got storyboard");
    
    _punchVC = [stb instantiateViewControllerWithIdentifier:@"punch"];
    _firstVC = [stb instantiateViewControllerWithIdentifier:@"specials"];
    _secondVC = [stb instantiateViewControllerWithIdentifier:@"coffees"];
    
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:_punchVC
                                                                                    leftViewController:_firstVC
                                                                                   rightViewController:_secondVC];
    NSLog(@"added vc's to new deck controller");
    deckController.rightLedge = 10;
    deckController.leftLedge = 10;
    
    self.window.rootViewController = deckController;
    NSLog(@"set deck controller as root view controller");
    [self.window makeKeyAndVisible];
    NSLog(@"make window key and visible");
    //end stuff for viewDeck
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [TestFlight passCheckpoint:@"APP_DID_ENTER_BACKGROUND"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [TestFlight passCheckpoint:@"APP_WILL_TREMINATE"];
}



@end
