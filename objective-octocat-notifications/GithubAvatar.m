// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// GithubAvatar.h
// objective-octocat-notifications
//

#import "GithubAvatar.h"
#import "OonLog.h"

@implementation GithubAvatar

+ (GithubAvatar *)backgroundImageForSize:(NSSize)size
{
    GithubAvatar *avatar_bg = [[GithubAvatar alloc] initWithSize:size];
    [avatar_bg lockFocus];

    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];

    [NSGraphicsContext saveGraphicsState];

    CGContextSetRGBFillColor (myContext, 1, 1, 1, 0.9);

    NSBezierPath *path = [NSBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];

    [path fill];

    [NSGraphicsContext restoreGraphicsState];

    [avatar_bg unlockFocus];
    return avatar_bg;
}

+ (GithubAvatar *)avatarFromURL:(NSURL *)url
{
    [OonLog forLevel:OonLogDebug with:@"avatar url: %@", url];
    GithubAvatar *avatar = [[GithubAvatar alloc] initWithContentsOfURL:url];

    GithubAvatar *bg = [self backgroundImageForSize:avatar.size];

    [bg lockFocus];
    [avatar drawInRect:CGRectMake(0, 0, avatar.size.width, avatar.size.height)];
    [bg unlockFocus];
    return bg;


    return [self backgroundImageForSize:NSMakeSize(64, 64)];
}

@end
