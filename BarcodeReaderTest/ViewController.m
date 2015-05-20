//
//  ViewController.m
//  BarcodeReaderTest
//
//  Created by anxs on 15/5/20.
//  Copyright (c) 2015年 tbago. All rights reserved.
//

#import "ViewController.h"
#import "BarcodeReaderViewController.h"

@interface ViewController () <BarcodeReaderViewControllerDelegate>

@property(nonatomic,strong) NSString     *qrCodeString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.qrCodeString != nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结果"
                                                        message:self.qrCodeString
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        self.qrCodeString = nil;
        [alert show];
    }
}

- (IBAction)scanQRCodeButtonClick:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BarcodeStoryboard" bundle:nil];
    BarcodeReaderViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"BarcodeReaderViewController"];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}

#pragma mark - BarcodeReaderViewControllerDelegate
- (void)scanedQRCode:(NSString *)qrCode
{
    self.qrCodeString = qrCode;
}
@end
