//
//  GGCSecondViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"

@interface GGCSecondViewController : UIViewController
<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray *nameArray;
    NSMutableArray *descripArray;
    TBXML *tbxml;
}

@property (nonatomic)NSMutableArray *nameArray;
@property (nonatomic)NSMutableArray *descripArray;
@property (weak, nonatomic) IBOutlet UILabel *coffeeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *coffeePicker;
@property (strong, nonatomic) NSArray *coffees;
@property (strong, nonatomic) NSArray *descrips;

- (void)fetchCoffees;

@end
