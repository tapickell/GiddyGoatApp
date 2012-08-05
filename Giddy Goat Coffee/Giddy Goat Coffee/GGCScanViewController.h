//
//  GGCScanViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 8/5/12.
//
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>
#import "ZBarReaderViewController.h"

@interface GGCScanViewController : UIViewController <ZBarReaderViewDelegate>
{
    NSString *scan;
    PKPassLibrary *passLib;
    NSArray *passes;
    NSURL *url;
    NSData *data;
    PKPass *updatedPass;
    ZBarReaderView *readerView;
}

@property (nonatomic) IBOutlet ZBarReaderView *readerView;
@property (weak, nonatomic)PKPassLibrary *passLib;
@property (weak, nonatomic)NSArray *passes;

- (IBAction)cancelButtonPressed:(id)sender;

- (IBAction)scanPunchCode:(id)sender;

- (void)processPunchScan;

- (void)getPassFromServer:(NSMutableString *)urlString;

@end
