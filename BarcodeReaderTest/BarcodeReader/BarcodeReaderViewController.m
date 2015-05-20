//
//  BarcodeReaderViewController.m
//  tbago
//
//  Created by anxs on 15/5/19.
//  Copyright (c) 2015年 tbago. All rights reserved.
//

#import "BarcodeReaderViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface BarcodeReaderViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *interestView;

@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property(nonatomic) float areaWidth;
@property(nonatomic) float areaXWidth;
@property(nonatomic) float areaYHeight;

@property(nonatomic, strong) CALayer *borderLayer;

@property(nonatomic,strong) UIButton        *deleteButton;

@end

@implementation BarcodeReaderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadBeepSound];
    
    self.areaWidth = 3.0f;
    self.areaXWidth = 30.0f;
    self.areaYHeight = 30.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![self startReading]) {
        [self stopReading];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"错误"
                              message:@"访问摄像头失败，请确认程序有权访问摄像头！"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:@"取消",nil];
        [alert show];
    }
}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (nil == input) {         ///<无法访问摄像头，可能是用户禁止访问
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    [self.captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    CGRect cropRect = self.interestView.frame;
    CGSize size = self.view.bounds.size;
    
    captureMetadataOutput.rectOfInterest = CGRectMake(cropRect.origin.x/size.width,
                                                      cropRect.origin.y/size.height,
                                                      cropRect.size.width/size.width,
                                                      cropRect.size.height/size.height);
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.view.layer.bounds];
    self.videoPreviewLayer.connection.videoOrientation = [[UIDevice currentDevice] orientation];
    [self.view.layer addSublayer:self.videoPreviewLayer];
    
    //add it to our view
    [self.view.layer addSublayer:self.borderLayer];
    [self.borderLayer setNeedsDisplay];
    
    [self.view addSubview:self.deleteButton];
    [self.captureSession startRunning];
    
    return YES;
}

- (void)stopReading
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    
    [self.borderLayer removeFromSuperlayer];
    
    [self.videoPreviewLayer removeFromSuperlayer];
}

- (void)loadBeepSound
{
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        [self.audioPlayer prepareToPlay];
    }
}

- (UIButton *)deleteButton
{
    if (nil == _deleteButton)
    {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_deleteButton addTarget:self
                          action:@selector(deleteButtonClick:)
                forControlEvents:UIControlEventTouchUpInside];
        [_deleteButton setTitle:@"X" forState:UIControlStateNormal];
        _deleteButton.frame = CGRectMake(self.view.bounds.size.width - 100, 100.0f, 30.0, 30.0);
        _deleteButton.layer.cornerRadius = 15.0;
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deleteButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _deleteButton;
}

- (void)deleteButtonClick:(id)sender
{
    [self performSelectorOnMainThread:@selector(callDelegateAndGoBack:)
                           withObject:nil
                        waitUntilDone:NO];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            if (self.audioPlayer) {
                [self.audioPlayer play];
            }
            [self performSelectorOnMainThread:@selector(callDelegateAndGoBack:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        }
    }
}

- (void)callDelegateAndGoBack:(NSString *) qrCode
{
    [self stopReading];
    if (self.delegate) {
        [self.delegate scanedQRCode:qrCode];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
}

- (CALayer *)borderLayer
{
    if (nil == _borderLayer) {
        _borderLayer = [CALayer layer];
        _borderLayer.frame = self.interestView.frame;
        _borderLayer.delegate = self;
    }
    return _borderLayer;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef) context
{
    CGContextSetLineWidth(context, self.areaWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    UIBezierPath*    topLeftBezierPath = [[UIBezierPath alloc] init];
    
    [topLeftBezierPath moveToPoint:CGPointMake(0.0, 0.0)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaXWidth, 0.0f)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaXWidth, self.areaWidth)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaWidth, self.areaWidth)];
    [topLeftBezierPath addLineToPoint:CGPointMake(self.areaWidth, self.areaYHeight)];
    [topLeftBezierPath addLineToPoint:CGPointMake(0.0f, self.areaYHeight)];
    [topLeftBezierPath closePath];
    
    CGContextBeginPath(context);
    CGContextAddPath(context, topLeftBezierPath.CGPath);
    
    UIBezierPath *topRightPath = [[UIBezierPath alloc] init];
    
    [topRightPath moveToPoint:CGPointMake(layer.bounds.size.width, 0.0f)];
    [topRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaXWidth, 0.0f)];
    [topRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaXWidth, self.areaWidth)];
    [topRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaWidth, self.areaWidth)];
    [topRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaWidth, self.areaYHeight)];
    [topRightPath addLineToPoint:CGPointMake(layer.bounds.size.width, self.areaYHeight)];
    [topRightPath closePath];
    CGContextAddPath(context, topRightPath.CGPath);
    
    UIBezierPath *bottomLeftPath = [[UIBezierPath alloc] init];
    [bottomLeftPath moveToPoint:CGPointMake(0.0f, layer.bounds.size.height)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaXWidth, layer.bounds.size.height)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaXWidth, layer.bounds.size.height - self.areaWidth)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaWidth, layer.bounds.size.height - self.areaWidth)];
    [bottomLeftPath addLineToPoint:CGPointMake(self.areaWidth, layer.bounds.size.height - self.areaYHeight)];
    [bottomLeftPath addLineToPoint:CGPointMake(0.0f, layer.bounds.size.height - self.areaYHeight)];
    [bottomLeftPath closePath];
    CGContextAddPath(context, bottomLeftPath.CGPath);
    
    UIBezierPath *bottomRightPath = [[UIBezierPath alloc] init];
    [bottomRightPath moveToPoint:CGPointMake(layer.bounds.size.width, layer.bounds.size.height)];
    [bottomRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaXWidth, layer.bounds.size.height)];
    [bottomRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaXWidth, layer.bounds.size.height - self.areaWidth)];
    [bottomRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaWidth, layer.bounds.size.height - self.areaWidth)];
    [bottomRightPath addLineToPoint:CGPointMake(layer.bounds.size.width - self.areaWidth, layer.bounds.size.height - self.areaYHeight)];
    [bottomRightPath addLineToPoint:CGPointMake(layer.bounds.size.width, layer.bounds.size.height - self.areaYHeight)];
    [bottomRightPath closePath];
    CGContextAddPath(context, bottomRightPath.CGPath);
    
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
@end
