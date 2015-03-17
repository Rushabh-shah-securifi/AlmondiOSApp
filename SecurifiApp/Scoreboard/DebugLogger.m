//
// Created by Matthew Sinclair-Day on 3/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "DebugLogger.h"


@interface DebugLogger ()
@property(nonatomic, readonly) NSFileHandle *fileHandle;
@property(nonatomic, readonly) NSObject *locker;
@end

@implementation DebugLogger

+ (DebugLogger *)instance {
    static DebugLogger *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            [_instance open];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _locker = [NSObject new];
    }

    return self;
}


- (void)open {
    @synchronized (self.locker) {
        NSString *fileName = [self loggerFilePath];
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];

        if (!self.fileHandle) {
            NSString *logStarted = [self makeLogStarted];
            [logStarted writeToFile:fileName
                         atomically:NO
                           encoding:NSStringEncodingConversionAllowLossy
                              error:nil];

            _fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        }
    }
}

- (void)close {
    @synchronized (self.locker) {
        [self.fileHandle closeFile];
    }
}

- (void)clear {
    @synchronized (self.locker) {
        NSFileHandle *handle = self.fileHandle;
        [handle truncateFileAtOffset:0];

        NSString *logStarted = [self makeLogStarted];
        [handle writeData:[logStarted dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (void)writeLog:(NSString *)msg {
    if (!msg) {
        return;
    }

    NSDate *now = [NSDate date];
    msg = [NSString stringWithFormat:@"%@ %@\n", now.formattedDateTimeString, msg];

    @synchronized (self.locker) {
        NSFileHandle *handle = self.fileHandle;
        [handle seekToEndOfFile];
        [handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

- (NSString *)logEntries {
    @synchronized (self.locker) {
        NSFileHandle *handle = self.fileHandle;
        if (handle == nil) {
            return @"No Entries\n";
        }

        NSString *path = [self loggerFilePath];
        NSError *error;
        NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

        if (error) {
            return [NSString stringWithFormat:@"Error reading entries\n%@", error.description];
        }

        return string;
    }
}

- (NSString *)loggerFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [NSString stringWithFormat:@"%@/debuglog.log", documentsDirectory];
}

- (NSString *)makeLogStarted {
    NSDate *now = [NSDate date];
    return [NSString stringWithFormat:@"%@ Log Started\n", now.formattedDateTimeString];
}

@end