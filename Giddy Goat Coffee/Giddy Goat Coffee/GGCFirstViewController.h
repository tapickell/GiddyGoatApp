//
//  GGCFirstViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TBXML.h"

@interface GGCFirstViewController : UIViewController{
    NSMutableArray *updateArray;
    TBXML *tbxml;


}

@property (nonatomic)AVAudioPlayer *audio;
@property (nonatomic)NSMutableArray *updateArray;
@property (weak, nonatomic) IBOutlet UILabel *specialsLabel;

- (IBAction)gotoMap:(id)sender;
- (IBAction)gotoFB:(id)sender;
- (IBAction)gotoTwitter:(id)sender;


- (void)getStatusData;
- (void)fetchSpecials;
- (NSString *)statusArrayFilePath;

- (void)compareDates:(NSArray *)arrayFromFile months_p:(NSInteger *)months_p days_p:(NSInteger *)days_p;

@end
