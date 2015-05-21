//
//  BarcodeReaderViewController.h
//  tbago
//
//  Created by anxs on 15/5/19.
//  Copyright (c) 2015年 tbago. All rights reserved.
//

#import <UIKit/UIKit.h>

enum ScanType
{
    QRCode,     ///<只支持二维码扫描
    BarCode,    ///<同时支持二维码和条形码
};

@protocol BarcodeReaderViewControllerDelegate <NSObject>

- (void)scanedBarcodeResult:(NSString *) barcodeResult;
@end

@interface BarcodeReaderViewController : UIViewController

@property(nonatomic,strong) id<BarcodeReaderViewControllerDelegate> delegate;

@property(nonatomic) enum ScanType scanType;
@end
