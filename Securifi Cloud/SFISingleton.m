////
////  SFISingleton.m
////  Securifi Cloud
////
////  Created by Nirav Uchat on 6/3/13.
////  Copyright (c) 2013 Securifi. All rights reserved.
////
//
//#import "SFISingleton.h"
//#import <SecurifiToolkit/SecurifiToolkit.h>
//#import <SecurifiToolkit/LoginResponse.h>
//
//@implementation SFISingleton
//@synthesize deviceid;
//@synthesize inputStream, outputStream;
//@synthesize expectedLength,totalReceivedLength;
//@synthesize command;
//
//static SFISingleton *single=nil;
//
//+(SFISingleton *)createSingletonObj{
//    @synchronized(self)
//    {
//        if (!single)
//        {
//            NSLog(@"Creating singleton Object from singleton class");
//            single = [[SFISingleton alloc] init];
//            [single initNetworkCommunication];
//        }
//    }
//    return single;
//}
//
//
//
//-(void) initNetworkCommunication{
//    
//    CFReadStreamRef readStream;
//	CFWriteStreamRef writeStream;
//	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"ec2-54-226-236-86.compute-1.amazonaws.com", 1028, &readStream, &writeStream);
//	
//	inputStream = (__bridge NSInputStream *)readStream;
//	outputStream = (__bridge NSOutputStream *)writeStream;
//    
//	[inputStream setDelegate:self];
//	[outputStream setDelegate:self];
//	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//	[inputStream open];
//	[outputStream open];
//    
//    [inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
//                      forKey:NSStreamSocketSecurityLevelKey];
//    [outputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL
//                       forKey:NSStreamSocketSecurityLevelKey];
//    
//    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
//                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
//                              [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
//                              [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
//                              kCFNull,kCFStreamSSLPeerName,
//                              nil];
//    
//    CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
//    CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
//}
//
//
//- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
//    
//    if (!partialData)
//    {
//        partialData = [[NSMutableData alloc] init];
//    }
//
//    NSString *endTagString = @"</root>";
//    NSData *endTag = [endTagString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSString *startTagString = @"<root>";
//    NSData *startTag = [startTagString dataUsingEncoding:NSUTF8StringEncoding];
//    
//	//NSLog(@"stream event %i", streamEvent);
//	switch (streamEvent) {
//			
//		case NSStreamEventOpenCompleted:
//			//NSLog(@"Stream opened");
//			break;
//		case NSStreamEventHasBytesAvailable:
//			if (theStream == inputStream) {
//				while ([inputStream hasBytesAvailable]) {
//                    uint8_t inputBuffer[4096];
//                    int len;
//                    
//                    //Multiple entry in one callback possible
//					len = [inputStream read:inputBuffer maxLength:sizeof(inputBuffer)];
//					if (len > 0) {
//						NSLog(@"Length : %d",len);
//                        //If current stream has </root>
//                        //1. Get NSRange and prepare command
//                        //2. If command has parital command add it to mutableData object
//                        //3. It mutable object has some data append new received Data to it
//                        //4. repeat this procedure for newly created mutableData
//                        
//                        //Append received data to paritial buffer
//                        [partialData appendBytes:&inputBuffer[0] length:len];
//                        
//                        //Initialize range 
//                        NSRange endTagRange = NSMakeRange(0, [partialData length]);
//                        int count=0;
//                        
//                        //NOT NEEDED- Convert received buffer to NSMutableData
//                        //[totalReceivedData appendBytes:&inputBuffer[0] length:len];
//                        
//                        while (endTagRange.location != NSNotFound)
//                        {
//                            endTagRange = [partialData rangeOfData:endTag options:0 range:endTagRange];
//                            if(endTagRange.location != NSNotFound)
//                            {
//                                NSLog(@"endTag Location: %i, Length: %i",endTagRange.location,endTagRange.length);
//                                
//                                //Look for <root> tag in [0 to endTag]
//                                NSRange startTagRange = NSMakeRange(0, endTagRange.location);
//                                
//                                startTagRange = [partialData rangeOfData:startTag options:0 range:startTagRange];
//                                
//                                if(startTagRange.location == NSNotFound)
//                                {
//                                    NSLog(@"Seriouse error !!! should not come heer // Invalid command /// without startRootTag");
//                                }
//                                else
//                                {
//                                    NSLog(@"startTag Location: %i, Length: %i",startTagRange.location,startTagRange.length);
//                                    //Prepare Command
//                                    [partialData getBytes:&expectedLength range:NSMakeRange(0, 4)];
//                                    NSLog(@"Expected Length: %d",NSSwapBigIntToHost(expectedLength));
//                                    
//                                    [partialData getBytes:&command range:NSMakeRange(4,4)];
//                                    NSLog(@"Command: %d",NSSwapBigIntToHost(command));
//                                    
//                                    //Remove 8 bytes from received command
//                                    [partialData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
//                                    
//                                    //MIGRATING TO SDK
//                                    /*
//                                     LoginResponse *temp = (LoginResponse *)[SecurifiToolkit parseXML:partialData];
//                                    
//                                    NSLog(@"MAIN APP User ID : %@",[temp userID]);
//                                    NSLog(@"MAIN APP TempPass : %@", [temp tempPass]);
//                                    NSLog(@"MAIN APP isSuccessful : %d",[temp isSuccessful]);
//                                    
//                                    NSDictionary *data = [NSDictionary dictionaryWithObject:[temp userID] forKey:@"data"];
//                                    
//                                    NSLog(@"Before Pused Notification");
//                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
//                                    
//                                    NSLog(@"After Pused Notification");
//                                    */
//                                    
//                                    
//                                    /* MIGRATING TO iOS SDK
//                                    if (NSSwapBigIntToHost(command) == 2)
//                                    {
//                                        NSLog(@"Inside command == 2");
//                                    //Create Notification and send it
//                                    NSString *output = [[NSString alloc] initWithData:partialData encoding:NSUTF8StringEncoding];
//                                    
//                                    if (nil != output) {
//                                        NSLog(@"server said: %@", output);
//                                        //[self messageReceived:output];
//                                        //send local notification to update view
//                                        NSDictionary *data = [NSDictionary dictionaryWithObject:output forKey:@"data"];
//                                        
//                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
//                                        
//                                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"tempPassLogingRes" object:self userInfo:data];
//                                    }
//                                    }
//                                     
//                                    if ((NSSwapBigIntToHost(command) == 24) || (NSSwapBigIntToHost(command) == 26))
//                                    {
//                                        NSLog(@"Inside command == %d",NSSwapBigIntToHost(command));
//                                                //Create Notification and send it
//                                        NSString *output = [[NSString alloc] initWithData:partialData encoding:NSUTF8StringEncoding];
//                                                
//                                        if (nil != output) {
//                                        NSLog(@"server said: %@", output);
//                                                    //[self messageReceived:output];
//                                                    //send local notification to update view
//                                        NSDictionary *data = [NSDictionary dictionaryWithObject:output forKey:@"data"];
//                                                    
//                                        //[[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
//                                                }
//                                    }
//                                     */
//                                    
//                                    NSLog(@"Partial Buffer before trim : %@",partialData);
//                                    
//                                    //Trim Partial Buffer
//                                    //This will trim parital buffer till </root>
//                                    [partialData replaceBytesInRange:NSMakeRange(0, endTagRange.location+endTagRange.length - 8 /* Removed 8 bytes before */) withBytes:NULL length:0];
//                                    
//                                    //Regenerate NSRange
//                                    endTagRange = NSMakeRange(0, [partialData length]);
//                                    
//                                    NSLog(@"Partial Buffer after trim : %@",partialData);
//                                }
//                                count++; 
//                            }
//                            else
//                            {
//                                NSLog(@"Number of Command Processed  : %d",count);
//                                //At this point paritalBuffer will have unffinised command data
//                            }
//                        }
//#if 0
//                        totalReceivedLength+=len;
//                        NSLog(@"totalReceivedLength : %d",totalReceivedLength);
//                        
//                        if (totalReceivedLength < 8 && expectedLength == 0)
//                        {
//                        NSLog(@"received length less than 8");
//                        [totalReceivedData appendBytes:&inputBuffer[totalReceivedLength - len] length:len];
//                        }
//                        else if (totalReceivedLength >=8 && expectedLength == 0)
//                        {
//                            NSLog(@"Enough data to process ExpectedLength and Command");
//                            [totalReceivedData appendBytes:&inputBuffer[totalReceivedLength - len] length:len];
//                            
//                            NSLog(@"receivedData %@",totalReceivedData);
//                            [totalReceivedData getBytes:&expectedLength range:NSMakeRange(0, 4)];
//                            
//                            NSLog(@"Expected Length: %d",NSSwapBigIntToHost(expectedLength));
//                            
//                            [totalReceivedData getBytes:&command range:NSMakeRange(4,4)];
//                            NSLog(@"Command: %d",NSSwapBigIntToHost(command));
//                            
//                            //Check if this packet has all the data for given command
//                            //and prepare next command
//                        }
//                        
//						//NSString *output = [[NSString alloc] initWithBytes:&inputBuffer[0] length:NSSwapBigIntToHost(expectedLength) encoding:NSASCIIStringEncoding];
//                        
//                        //NSString *output = [[NSString alloc] initWithBytes:&inputBuffer[8] length:NSSwapBigIntToHost(expectedLength) encoding:NSUTF8StringEncoding];
//                        
//                        NSString *output = [[NSString alloc] initWithData:totalReceivedData encoding:NSASCIIStringEncoding];
//                        
//                        NSLog(@"NSString output  :%@",output);
//                        expectedLength=0;
//                        
//                        //NSString *output = [[NSString alloc] initWithData:totalReceivedData encoding:NSASCIIStringEncoding];
//						
//                        //NSString *output = [[NSString alloc] initWithData:totalReceivedData encoding:NSUTF8StringEncoding];
//                        
//						if (nil != output) {
//                            
//							NSLog(@"server said: %@", output);
//							//[self messageReceived:output];
//                            //send local notification to update view
//                            NSDictionary *data = [NSDictionary dictionaryWithObject:output forKey:@"data"];
//                            
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginResponse" object:self userInfo:data];
//						}
//#endif
//					}
//				}
//			}
//			break;
//			
//		case NSStreamEventErrorOccurred:
//			//NSLog(@"Can not connect to the host!");
//            NSLog(@"Connection event error");
//            //Cleanup stream -- taken from EventEndEncountered
//            //We should create new object of singleton class
//            if ([outputStream streamStatus] == NSStreamStatusError)
//            {
//                //If iPhone does not have internet connection ... it will loop thorugh this path
//                //need to slow down reconnect frequency
//                NSLog(@"Creating new connection from stream event");
//                [theStream close];
//                [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//                theStream = nil;
//                [self initNetworkCommunication];
//			}
//            break;
//			
//		case NSStreamEventEndEncountered:
//            NSLog(@"Event End Encountered");
//            //Happens when cloud close the connection .. retry to connect
//            [theStream close];
//            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//            //[theStream release];
//            theStream = nil;
//            [self initNetworkCommunication];
//			break;
//		default:
//			NSLog(@"Unknown event");
//	}
//    
//}
//@end
