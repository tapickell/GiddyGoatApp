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
//  GGCScanViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 8/5/12.
//
//



#import "GGCScanViewController.h"

@interface GGCScanViewController ()

@end

@implementation GGCScanViewController

@synthesize readerView;
@synthesize passLib = _passLib;
@synthesize passes = _passes;

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
    [self getPunchesOnViewDidLoad];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)];
    [_spinner setColor:[UIColor greenColor]];
    [self.view addSubview:_spinner];
    readerView.readerDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [readerView start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [readerView stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - passbook bypass

- (void)getPunchesOnViewDidLoad
{
    number_of_punches = [self getPunchesFromLocalStorage];
    [self updatePunchLabel];
}

- (NSInteger)getPunchesFromLocalStorage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:@"punches"];
}

- (void)savePunchesToLocalStorage:(NSInteger)punches
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:punches forKey:@"punches"];
}

- (void)updatePunchLabel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_punchLabel setText:[NSString stringWithFormat:@"%d", number_of_punches]];
    });
}

- (NSInteger)processNumberOfPunches:(NSInteger)punches
{
    if (punches >= 10) {
        return 0;
    } else {
        return punches + 1;
    }
}

#pragma mark - scanner integration

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    for(ZBarSymbol *sym in symbols) {
        scan = sym.data;
        break;
    }
    [self processPunchScan];
}

- (void)updateCardFromServer
{
    PKPass *myPass = [passes objectAtIndex:0];
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://www.toddpickell.me/card/punchMe.php?cn="];
    [urlString appendString:[myPass serialNumber]];
    [urlString appendString:@"&cp="];
    [urlString appendString:[myPass localizedValueForFieldKey:@"punches"]];

    dispatch_queue_t passUpdateQueue = dispatch_queue_create("pass update downloader", NULL);
    dispatch_async(passUpdateQueue, ^{
        [self getPassFromServer:urlString];
        if (updatedPass != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [passLib replacePassWithPass:updatedPass];
                if ([_spinner isAnimating]) {
                    [_spinner stopAnimating];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    });
}

- (void)updateCardInternally
{
    [self savePunchesToLocalStorage:[self processNumberOfPunches:number_of_punches]];
    [self getPunchesFromLocalStorage];
    [self updatePunchLabel];
    if ([_spinner isAnimating]) {
        [_spinner stopAnimating];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)processPunchScan
{
    [_spinner startAnimating];
    NSString *checkString = @"2a73e02a88ee9bcb965cc0f22c0cabbf68d5e823992884b4514bc242b0146ff16d5cf349c374cf7c";
    if ([scan isEqualToString:checkString]) {
        [self updateCardInternally];
    } else {
        UIAlertView *scanAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Scan" message:@"Scan does not match, please try again. If unable to get scan to work contact administrator." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        if ([_spinner isAnimating]) {
            [_spinner stopAnimating];
        }
        [scanAlert show];
    }
}

#pragma mark - passbook integration

- (void)getPassFromServer:(NSMutableString *)urlString
{
    url = [NSURL URLWithString:urlString];
    data = [[NSData alloc] initWithContentsOfURL:url];
    if (data != NULL) {
        updatedPass = [[PKPass alloc] initWithData:data error:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"Unable to connect to server to update punch card. Please check your network connection and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - old scan methods



- (IBAction)scanPunchCode:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:0];
    reader.readerView.zoom = 1.0;
    [self presentViewController:reader animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    scan = symbol.data;
    [self dismissViewControllerAnimated:YES completion:^{ [self processPunchScan]; }];
}



- (void)viewDidUnload {
    [self setPunchLabel:nil];
    [super viewDidUnload];
}
@end
