//
//  SFIUserProfile.h
//  Almond
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//


@interface SFIUserProfile : NSObject
@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSString *keyValue;
@property (nonatomic) NSMutableArray *data;
@property (nonatomic) NSMutableArray *placeHolders;
@end
