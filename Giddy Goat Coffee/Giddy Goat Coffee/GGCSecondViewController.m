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
//  GGCSecondViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCSecondViewController.h"
#import "IIViewDeckController.h"


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
//    [self getMenuDisplay];
    NSLog(@"second view did load");
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

- (IBAction)returnToCenter:(id)sender
{
    [self.viewDeckController toggleRightViewAnimated:YES];
    [TestFlight passCheckpoint:@"Button nav from coffees view"];
}
@end
