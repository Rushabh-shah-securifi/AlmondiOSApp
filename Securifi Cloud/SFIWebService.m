//
//  SFIWebService.m
//  Securifi Cloud
//
//  Created by Securifi on 20/12/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFIWebService.h"

@implementation SFIWebService
@synthesize delegate;

- (void)initWithURL:(NSMutableURLRequest *)url andDelegate:(id<myWebServiceDelegate>)del
{
	//if (self = [super init])
	{
        self.delegate = del;
        
		NSMutableURLRequest *request = url;
        
		connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
		[connection start];
	}
    
	//return self;
}

- (void)dealloc
{
	[connection cancel];
	//[connection release];
    
	//[receivedData release];
    
	//[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// every response could mean a redirect
	//[receivedData release];
    receivedData = nil;
    
	// need to record the received encoding
	// http://stackoverflow.com/questions/1409537/nsdata-to-nsstring-converstion-problem
	CFStringEncoding cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)
                                                                           [response textEncodingName]);
	encoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (!receivedData)
	{
		// no store yet, make one
		receivedData = [[NSMutableData alloc] initWithData:data];
	}
	else
	{
		// append to previous chunks
		[receivedData appendData:data];
       // NSLog(@"Data %@",data);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *xml = [[NSString alloc] initWithData:receivedData encoding:encoding];
	NSLog(@"%@", xml);
    
    [delegate dataRequestCompletedWithXMLObject:xml];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error retrieving data, %@", [error localizedDescription]);
}

- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
	return [protectionSpace.authenticationMethod
			isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge.protectionSpace.authenticationMethod
		 isEqualToString:NSURLAuthenticationMethodServerTrust])
	{
		NSLog(@"hostString %@",challenge.protectionSpace.host);
        
        // we only trust our own domain
		if ([challenge.protectionSpace.host isEqualToString:@"ec2-54-242-107-108.compute-1.amazonaws.com"])
		{
			NSURLCredential *credential =
            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
		}
	}
    
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
@end
