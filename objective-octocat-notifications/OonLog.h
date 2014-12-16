//
//  OonLog.h
//  objective-octocat-notifications
//
//  Created by Daniel Paul Searles on 11/22/14.
//  Copyright (c) 2014 SquareSurf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdarg.h>

/**
 * Representation for the severity of a log message. It is used to control the log verbosity via the kOonLogLevel constant in the constants.h file.
 */
typedef enum : NSUInteger {
    // A major error.
    OonLogError,
    // A potential error.
    OonLogWarn,
    // Large amounts of data that could be useful to debugging.
    OonLogDebug,
} OonLogLevel;

/**
 * A custom logging class that can be used to define the severity of a log message and allow the message to be logged or ignored depending on kOonLogLevel.
 */
@interface OonLog : NSObject

/**
 * A function to log a message and define the serverity level. The function has the same form as NSLog except for the first parameter that defines the message's severity.
 *
 * @param level The severity of the message.
 * @param with  The format of the message. Followed by a variable length list of parameters that will be passed to the format.
 */
+ (void)forLevel: (OonLogLevel)level with:(NSString *)format, ...;

@end
