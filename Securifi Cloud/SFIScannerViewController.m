//
//  SFIScannerViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIScannerViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "SNLog.h"
@interface SFIScannerViewController ()

@end

@implementation SFIScannerViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

}

- (void)viewWillAppear:(BOOL)animated
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (!input)
    {
        [SNLog Log:@"Method Name: %s Error: %@", __PRETTY_FUNCTION__, error];
        return;
    }
    
    [ self.session addInput:input];
    
    //Turn on point autofocus for middle of view
    [device lockForConfiguration:&error];
    CGPoint point = CGPointMake(0.5,0.5);
    [device setFocusPointOfInterest:point];
    [device setFocusMode:AVCaptureFocusModeLocked];
    [device unlockForConfiguration];
    
    //Add the metadata output device
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [ self.session addOutput:output];
    
//    NSLog(@"%lu",(unsigned long)output.availableMetadataObjectTypes.count);
//    for (NSString *s in output.availableMetadataObjectTypes)
//        NSLog(@"%@",s);
    
    //You should check here to see if the session supports these types, if they aren't support you'll get an exception
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    output.rectOfInterest = self.livevideo.bounds;
    
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.session];
    newCaptureVideoPreviewLayer.frame = self.livevideo.bounds;
    newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.livevideo.layer insertSublayer:newCaptureVideoPreviewLayer above:self.livevideo.layer];
    
    [ self.session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *code;
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
        if([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            code =readableObject.stringValue;
             [SNLog Log:@"Method Name: %s QR Code: %@", __PRETTY_FUNCTION__, code];
             self.barcode.text = code;
        }
        
    }
    [self.session removeOutput:captureOutput];
    [self.session stopRunning];
   [SNLog Log:@"Method Name: %s QR Code captured", __PRETTY_FUNCTION__];
    //[[UIDevice currentDevice] playInputClick];
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"QR Code captured"
                                                      message:[NSString stringWithFormat:@"QR Code = %@", code]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}


- (BOOL) enableInputClicksWhenVisible {
    return YES;
}

@end
