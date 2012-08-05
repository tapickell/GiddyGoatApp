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
	// Do any additional setup after loading the view.
    
    passLib = [[PKPassLibrary alloc] init];
    passes = [passLib passes];
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
    // Dispose of any resources that can be recreated.
}


#pragma mark - scanner integration

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    // do something useful with results
    for(ZBarSymbol *sym in symbols) {
        scan = sym.data;
        break;
    }
    [self processPunchScan];
}

- (void)processPunchScan
{
    NSLog(@"Scan: %@", scan);
    NSString *checkString = @"2a73e02a88ee9bcb965cc0f22c0cabbf68d5e823992884b4514bc242b0146ff16d5cf349c374cf7c";
    if ([scan isEqualToString:checkString]) {
        //get updated pass from server
        PKPass *myPass = [passes objectAtIndex:0];
        NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://mini.local/~toddpickell/punchMe?cn="];
        [urlString appendString:[myPass serialNumber]];
        [urlString appendString:@"&cp="];
        [urlString appendString:[myPass localizedValueForFieldKey:@"punches"]];
        
        dispatch_queue_t passUpdateQueue = dispatch_queue_create("pass update downloader", NULL);
        dispatch_async(passUpdateQueue, ^{
            [self getPassFromServer:urlString];
            if (updatedPass != NULL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [passLib replacePassWithPass:updatedPass];
                    [self dismissModalViewControllerAnimated:YES];
                });
            }
        });
    } else {
        NSLog(@"Invalid Scan");
        UIAlertView *scanAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Scan" message:@"Scan does not match, please try again. If unable to get scan to work contact administrator." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        //warning unable to contact server
        NSLog(@"Unable to contact server");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"Unable to connect to server to update punch card. Please check your network connection and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - old scan methods



- (IBAction)scanPunchCode:(id)sender {
    //present scanner
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    //reader.readerDelegate = self;
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:0];
    reader.readerView.zoom = 1.0;
    [self presentModalViewController:reader animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController didFinishPicking");
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    scan = symbol.data;
    [self dismissViewControllerAnimated:YES completion:^{ [self processPunchScan]; }];
}



@end