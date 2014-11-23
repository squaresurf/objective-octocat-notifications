//
//  OonLog.m
//  objective-octocat-notifications
//
//  Created by Daniel Paul Searles on 11/22/14.
//  Copyright (c) 2014 SquareSurf. All rights reserved.
//

#import "OonLog.h"
#import "constants.h"

@implementation OonLog

+ (void)forLevel: (OonLogLevel)level with:(NSString *)format, ...;
{
    if (kOonLogLevel < level) {
        return;
    }

    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);
}

@end
