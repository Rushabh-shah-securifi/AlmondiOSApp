//
//  MeshEditViewController.h
//  SecurifiApp
//
//  Created by Masood on 10/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MeshEditViewControllerDelegate
-(void)slaveNameDidChangeDelegate:(NSString *)name;
@end

@interface MeshEditViewController : UIViewController
@property (nonatomic) NSString *uniqueName;
@property (nonatomic) id<MeshEditViewControllerDelegate> delegate;
@end
