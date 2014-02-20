//
//  SFIWebService.h
//  Securifi Cloud
//
//  Created by Securifi on 20/12/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  myWebServiceDelegate;


@interface SFIWebService : NSObject
{
    NSMutableData *receivedData;
    NSURLConnection *connection;
    NSStringEncoding encoding;
}
@property (nonatomic, assign) id<myWebServiceDelegate> delegate;

- (void)initWithURL :(NSMutableURLRequest*)urlString andDelegate:(id<myWebServiceDelegate>)delegate;
//- (id)initWithURL:(NSMutableURLRequest *)url;
@end

@protocol myWebServiceDelegate <NSObject>

-(void)dataRequestCompletedWithXMLObject:(id)xmlObject;

@end
