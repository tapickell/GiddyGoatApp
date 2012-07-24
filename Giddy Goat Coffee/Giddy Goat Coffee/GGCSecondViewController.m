//
//  GGCSecondViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCSecondViewController.h"

@interface GGCSecondViewController ()

@end

@implementation GGCSecondViewController
@synthesize coffeeLabel;
@synthesize coffeePicker;
@synthesize coffees = _coffees;
@synthesize descrips = _descrips;

@synthesize nameArray, descripArray;

- (void)viewWillAppear:(BOOL)animated
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self fetchCoffees];
    
        //load nsarray objects
    _coffees = [[NSArray alloc] initWithArray:nameArray copyItems:YES];

    _descrips = [[NSArray alloc] initWithArray:descripArray copyItems:YES];
}

- (void)viewDidUnload
{
    [self setCoffeePicker:nil];
    [self setCoffeeLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_coffees count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_coffees objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [coffeeLabel setText:[_descrips objectAtIndex:row]];
}

#pragma mark - XML methods

- (void)fetchCoffees
{    
        //data container for xml from service
    nameArray = [[NSMutableArray alloc] init];
    descripArray = [[NSMutableArray alloc] init];
    
    NSString *space = @"  ";
    
    [nameArray addObject:space];
    [descripArray addObject:space];
    
    tbxml = [TBXML tbxmlWithXMLFile:@"coffees.xml"];
    
        //obtain root element
    TBXMLElement * root = tbxml.rootXMLElement;
    if (root) {
            //NSLog(@"Got Root Element");
        TBXMLElement * elem_coffees = [TBXML childElementNamed:@"coffees" parentElement:root];
        while (elem_coffees != nil) {
                //NSLog(@"elem_coffees != nil");
            
            TBXMLElement * elem_name = [TBXML childElementNamed:@"name" parentElement:elem_coffees];
            NSString *name = [TBXML textForElement:elem_name];
                //NSLog(@"NAME: %@", name);
            [nameArray addObject:name];
            
            TBXMLElement * elem_descrip = [TBXML childElementNamed:@"descrip" parentElement:elem_coffees];
            NSString *descrip = [TBXML textForElement:elem_descrip];
                //NSLog(@"DESCRIP: %@", descrip);
            [descripArray addObject:descrip];
            
            elem_coffees = [TBXML nextSiblingNamed:@"coffees" searchFromElement:elem_coffees];
        }
    }
}



@end
