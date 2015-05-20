//
//  BarcodeReaderViewController.h
//  htl
//
//  Created by anxs on 15/5/19.
//  Copyright (c) 2015年 guofeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BarcodeReaderViewControllerDelegate <NSObject>

- (void)scanedQRCode:(NSString *) qrCode;
@end

@interface BarcodeReaderViewController : UIViewController

@property(nonatomic,strong) id<BarcodeReaderViewControllerDelegate> delegate;
@end
