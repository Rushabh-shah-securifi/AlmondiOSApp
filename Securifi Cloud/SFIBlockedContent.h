//
//  SFIBlockedContent.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 13/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIBlockedContent : NSObject
//<BlockedText>abcd</BlockedText>
@property (nonatomic, retain) NSString* blockedText;

//For UI purpose
@property BOOL isSelected;
@end
