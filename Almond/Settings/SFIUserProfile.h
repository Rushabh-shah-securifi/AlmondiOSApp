//
//  SFIUserProfile.h
//  Almond
//
//  Created by Securifi-Mac2 on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIUserProfile : NSObject
@property (nonatomic, retain) NSString* userEmail;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *addressLine1;
@property (nonatomic, retain) NSString *addressLine2;
@property (nonatomic, retain) NSString *addressLine3;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *zipCode;
@property BOOL isExpanded;
@end
