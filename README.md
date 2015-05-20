# BarcodeReader
iOS版本二维码扫描，参照QQ二维码扫描，采用屏幕特定区域扫描。效果图如下：
##调用示例代码:
```objective-c
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
```
