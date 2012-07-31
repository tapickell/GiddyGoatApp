//
//  GGCPunchViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/30/12.
//
//

#import "GGCPunchViewController.h"

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
    AwesomeMenuItem *menuItem1 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"map-marker.png"]];
    AwesomeMenuItem *menuItem2 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bubbleIcon.png"]];
    AwesomeMenuItem *menuItem3 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"pricetag.png"]];
    AwesomeMenuItem *menuItem4 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"coffeeCup.png"]];
    AwesomeMenuItem *menuItem5 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"group.png"]];
    AwesomeMenuItem *menuItem6 = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"phone.png"]];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
