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
@property (weak, nonatomic) IBOutlet UILabel *punchLabel;
@property (nonatomic)UIActivityIndicatorView *spinner;

- (IBAction)cancelButtonPressed:(id)sender;

- (IBAction)scanPunchCode:(id)sender;

- (void)processPunchScan;

- (void)getPassFromServer:(NSMutableString *)urlString;

@end
