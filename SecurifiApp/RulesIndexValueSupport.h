//
//  RulesIndexValueSupport.h
//  SecurifiApp
//
//  Created by Masood on 07/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

//used in rules view
#import <Foundation/Foundation.h>

@interface RulesIndexValueSupport : NSObject

@property(nonatomic) NSString *displayText;
@property(nonatomic) NSString *matchData;
@property(nonatomic) NSString *iconName;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *layoutType;
@property(nonatomic) NSString *suffix;
@property(nonatomic) sfi_id deviceID;
@property(nonatomic) int indexID;
@property(nonatomic) NSString* delay;
@property(nonatomic) int positionId;

@end
