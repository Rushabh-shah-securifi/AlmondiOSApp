/*!
    @header SNLog
    @abstract   Very simple logging framework for iOS apps
    @discussion SNLog is a simple-to-use replacement for NSLog (even re-defines it) allowing the use of multiple log strategies.
	Usage example: [SNLog Log:"@Log text %@", aString];
*/

#import <Foundation/Foundation.h>

// Re-define NSLog to use SNLog instead
#define NSLog(format, ...) [SNLog Log:format, ##__VA_ARGS__]


/*!
    @protocol
    @abstract    Protocol for all SNLog log strategies
    @discussion  Any custom log strategies for SNLog must implement this protocol
*/
@protocol SNLogStrategy

/*!
 Writes data to the particular log strategy
 */
- (void)writeToLog:(NSInteger)logLevel entry:(NSString *)logData;

@property(nonatomic) NSInteger logAtLevel;

@end


/*!
    @class
    @abstract    SNLog drop-in replacement for NSLog
    @discussion  This class implements SNLog as a singleton object and allows for multiple, simultaneous logging strategies
*/

@interface SNLog : NSObject

/*!
 Returns the shared log instance for any setup (adding strategies, etc.)
 @return SNLog singleton
 */
+ (SNLog *)logManager;

/*!
 Sends the string format to the logs with the default log level (1)
 @param format NSString format
 */
+ (void)Log:(NSString *)format, ...;

/*!
 Sends the string format to the logs
 @param format NSString format
 @param logLevel Logging level, the higher the level the more important
 */
+ (void)Log:(NSInteger)logLevel format:(NSString *)format, ...;

//PY 240913 - To read log file
+ (NSString *)readLogs;

+ (NSString *)readSDKLogs;

/*!
 Writes the given log entry to all the logs.  Use the class method Log instead.
 @param logEntry Log entry to write
 */
- (void)writeToLogs:(NSInteger)logLevel entry:(NSString *)logEntry;

/*!
 Adds a new log strategy to SNLog.  Must implement the SNLogStrategy protocol.
 @param logStrategy Object which implements the SNLogStrategy protocol
 */
- (void)addLogStrategy:(id <SNLogStrategy>)logStrategy;

/*!
 Creates the final log entry string
 */
- (NSString *)formatLogEntry:(NSInteger)logLevel :(NSString *)logData;

@end


/*!
    @class
    @abstract    Console logging strategy for SNLog
    @discussion  This class implements a logging strategy which writes to the console while debugging.
*/

@interface SNConsoleLogger : NSObject <SNLogStrategy>

@end


/*!
    @class
    @abstract    File logging strategy for SNLog
    @discussion  This class implements a logging strategy which write to a given file.
*/

@interface SNFileLogger : NSObject <SNLogStrategy>

/*!
 Constructs a new SNFileLogger with the given file path
 @param filePath Path to log file
 @param truncateSize Truncates log file at the given bytes
 @return New instance
 */
- (id)initWithPathAndSize:(NSString *)filePath truncateTo:(NSInteger)truncateSize;

@end


