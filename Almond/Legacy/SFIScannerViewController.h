//
//  SFIScannerViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface SFIScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,  UIInputViewAudioFeedback>

@property (strong, nonatomic) IBOutlet UILabel *barcode;
@property (strong, nonatomic) IBOutlet UIView *livevideo;
@property (strong,nonatomic) AVCaptureSession *session;
@end