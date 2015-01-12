// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// OonNotificationContentImage.m
// objective-octocat-notifications
//

#import "OonNotificationContentImage.h"
#import "OonLog.h"

@implementation OonNotificationContentImage

+ (OonNotificationContentImage *)backgroundImageForSize:(NSSize)size
{
    OonNotificationContentImage *image_bg = [[OonNotificationContentImage alloc] initWithSize:size];
    [image_bg lockFocus];

    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];

    [NSGraphicsContext saveGraphicsState];

    CGContextSetRGBFillColor (myContext, 1, 1, 1, 0.9);

    NSBezierPath *path = [NSBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];

    [path fill];

    [NSGraphicsContext restoreGraphicsState];

    [image_bg unlockFocus];
    return image_bg;
}

+ (OonNotificationContentImage *)imageFromURL:(NSURL *)url
{
    [OonLog forLevel:OonLogDebug with:@"image url: %@", url];
    return [self imageFromImage:[[OonNotificationContentImage alloc] initWithContentsOfURL:url]];
}

+ (OonNotificationContentImage *)imageFromImage:(NSImage *)image
{
    OonNotificationContentImage *bg = [self backgroundImageForSize:image.size];

    [bg lockFocus];
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [bg unlockFocus];
    return bg;
}

@end
