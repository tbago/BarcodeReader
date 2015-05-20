# BarcodeReader
iOS版本二维码扫描，参照QQ二维码扫描，采用屏幕特定区域扫描。效果图如下：
![ScreenShot](https://raw.githubusercontent.com/tbago/BarcodeReader/master/BarcodeReaderScreen.PNG)
当在屏幕绘制的矩形区域扫描到二维码后会通过声音提醒，同时返回到上一试图，并触发delegate函数。具体参照demo代码。
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
##代码说明：
我采用独立的storyboard封装了二维码扫描试图，方便复用。同时在二维码扫描后，采用delegate scanedQRCode:返回二维码数据。对于程序中的代码实现如果有兴趣了解的话，请参照[如何使用AVFoundation框架扫描QR Code](http://www.tbago.com/ios/qr-code-ios-programming-tutorial/)

## 联系 Support
* 发现问题请issues我，谢谢:)
* Email:owner@tbao.com
* Blog: http://www.tbago.com/

## 授权 License
本项目采用 [MIT license](http://opensource.org/licenses/MIT) 开源，你可以利用采用该协议的代码做任何事情，只需要继续继承 MIT 协议即可。
