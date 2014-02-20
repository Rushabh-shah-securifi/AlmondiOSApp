#import "SNLog.h"
#import "AlmondPlusConstants.h"

@implementation SNLog


#pragma mark Singleton Methods
static SNLog *sharedInstance;
+ (SNLog *) logManager {
	if (sharedInstance == nil) {
		sharedInstance = [[SNLog alloc] init];
	}
	
	return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone {
	if (sharedInstance == nil) {
		sharedInstance = [super allocWithZone:zone];
	}	
	return sharedInstance;
}


+ (void) Log: (NSString *) format, ... {
	SNLog *log = [SNLog logManager];
	va_list args;
	va_start(args, format);
	NSString *logEntry = [[NSString alloc] initWithFormat:format arguments:args];
	[log writeToLogs: 1 :logEntry];
}


+ (void) Log: (NSInteger) logLevel: (NSString *) format, ... {
	SNLog *log = [SNLog logManager];
	va_list args;
	va_start(args, format);
	NSString *logEntry = [[NSString alloc] initWithFormat:format arguments:args];
	[log writeToLogs:logLevel :logEntry];
	
}

+(NSString*) readLogs{
    NSString* logData = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingFormat:@"%@", LOG_FILE_NAME];
    logData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    return logData;
}

+(NSString*) readSDKLogs{
    NSString* logData = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingFormat:@"%@", SDK_LOG_FILE_NAME];
    logData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    return logData;
}
#pragma mark Instance Methods

- (void) writeToLogs: (NSInteger) logLevel: (NSString *) logEntry {
	NSString *formattedLogEntry = [self formatLogEntry:logLevel :logEntry];
	for (NSObject<SNLogStrategy> *logger in logStrategies) {
		if (logLevel >= logger.logAtLevel) {
			[logger writeToLog: logLevel: formattedLogEntry];
		}
	}
	
}

- (id) init {
	if (self = [super init]) {
		SNConsoleLogger *consoleLogger = [[SNConsoleLogger alloc] init];
		consoleLogger.logAtLevel = 0;
		[self addLogStrategy:consoleLogger];
		
		return self;
	 } else {
		 return nil;
	 }

	
}

- (void) addLogStrategy: (id<SNLogStrategy>) logStrategy {
	if (logStrategies == nil) {
		logStrategies = [[NSMutableArray alloc] init];
	}
	
	[logStrategies addObject: logStrategy];
}


- (NSString *) formatLogEntry: (NSInteger) logLevel: (NSString *) logData {
	NSDate *now = [NSDate date];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *formattedString = [dateFormatter stringFromDate:now];
	return [NSString stringWithFormat:@"[%i] - %@ - %@",logLevel, formattedString, logData];
}

@end







@implementation SNConsoleLogger
@synthesize logAtLevel;

- (void) writeToLog:(NSInteger) logLevel :(NSString *)logData {
	printf("%s\r\n", [logData UTF8String]);
}

@end










@implementation SNFileLogger

@synthesize logAtLevel;

- (id) init {
	logAtLevel = 0;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingFormat:@"%@", LOG_FILE_NAME];
	if (self = [super init]) {
		logFilePath = filePath;
		truncateBytes = 10240;
		return self;
	} else {
		return nil;
	}
}

- (id) initWithPathAndSize: (NSString *) filePath: (NSInteger) truncateSize {
	logAtLevel = 2;
	
	if (self = [super init]) {
		logFilePath = filePath;
		truncateBytes = truncateSize;
		return self;
	} else {
		return nil;
	}
}

- (void) writeToLog:(NSInteger) logLevel :(NSString *)logData {
	NSData *logEntry =  [[logData stringByAppendingString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
	NSFileManager *fm = [[NSFileManager alloc] init];

	if(![fm fileExistsAtPath:logFilePath]) {
		[fm createFileAtPath:logFilePath contents:logEntry attributes:nil];
	} else {
		NSDictionary *attrs = [fm attributesOfItemAtPath:logFilePath error:nil];
		NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
		if ([attrs fileSize] > truncateBytes) {
			[file truncateFileAtOffset:0];
		}
		
		[file seekToEndOfFile];
		[file writeData:logEntry];
		[file closeFile];
	}

	

}
@end
