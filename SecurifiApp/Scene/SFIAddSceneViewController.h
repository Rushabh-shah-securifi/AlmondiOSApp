//
//  SFIAddSceneViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFIAddSceneViewController : UIViewController


@property (nonatomic, strong) NSDictionary *sceneInfo;
@property (nonatomic, strong) NSDictionary *originalSceneInfo;
@property (nonatomic, assign) int index;

@end
