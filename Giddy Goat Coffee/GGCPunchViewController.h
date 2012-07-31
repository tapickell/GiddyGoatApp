//
//  GGCPunchViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/30/12.
//
//

#import <UIKit/UIKit.h>
#import "AwesomeMenu.h"
#import "AwesomeMenuItem.h"

@interface GGCPunchViewController : UIViewController <AwesomeMenuDelegate>
{
    //AwesomeMenu *menu;
}

@property (nonatomic, retain)IBOutlet AwesomeMenu *menu;

- (IBAction)gotoMap:(id)sender;

@end
