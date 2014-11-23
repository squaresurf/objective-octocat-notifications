//
//  OonLog.h
//  objective-octocat-notifications
//
//  Created by Daniel Paul Searles on 11/22/14.
//  Copyright (c) 2014 SquareSurf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdarg.h>

typedef enum : NSUInteger {
    OonLogError,
    OonLogWarn,
    OonLogDebug,
} OonLogLevel;

@interface OonLog : NSObject

+ (void)forLevel: (OonLogLevel)level with:(NSString *)format, ...;

@end
