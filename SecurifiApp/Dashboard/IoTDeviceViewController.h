//
//  IoTDeviceViewController.h
//  
//
//  Created by Securifi-Mac2 on 07/12/16.
//
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, SectionType) {
    vulnerable_section,
    healthy_section,
    excluded_section
    
};
@interface IoTDeviceViewController : UIViewController
@property (nonatomic) NSDictionary *iotDevice;
@property(nonatomic) SectionType sectionType;
@property BOOL hideMiddleView;
@property BOOL hideTable;
@end
