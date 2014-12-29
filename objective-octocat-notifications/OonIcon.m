// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// Icon.m
// objective-octocat-notifications
//

#import "OonIcon.h"

@implementation OonIcon

+ (OonIcon *)forStatusBarFrom:(OonIconType)iconType
{
    OonIcon *img = [[OonIcon alloc] initWithSize:NSMakeSize(18, 24)];
    [img lockFocus];

    CGContextRef myContext = [[NSGraphicsContext // 1
                               currentContext] graphicsPort];

    [NSGraphicsContext saveGraphicsState];

    switch (iconType) {
        case OonIconStatusBarDefault:
        {
            CGContextSetRGBFillColor (myContext, 0.1, 0.1, 0.1, 1);
            break;
        }
        case OonIconStatusBarActive:
        {
            CGContextSetRGBFillColor (myContext, 0.9, 0.9, 0.9, 1);
            break;
        }
        case OonIconStatusBarHasNotifications:
        {
            CGFloat red = 0.25490196078431;
            CGFloat green = 0.51372549019608;
            CGFloat blue = 0.76862745098039;

            CGContextSetRGBFillColor (myContext, red, green, blue, 1);

            NSShadow* theShadow = [[NSShadow alloc] init];
            [theShadow setShadowOffset:NSMakeSize(0, 0)];
            [theShadow setShadowBlurRadius:8.0];

            // Use a partially transparent color for shapes that overlap.
            [theShadow setShadowColor:[NSColor colorWithSRGBRed:red green:green blue:blue alpha:0.8]];

            [theShadow set];
            break;
        }
        default:
        {
            break;
        }
    }

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:CGRectMake(5, 8, 8, 8)];
    [path fill];

    [NSGraphicsContext restoreGraphicsState];
    [img unlockFocus];
    return img;
}

@end

