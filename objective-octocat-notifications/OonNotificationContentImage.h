// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// OonNotificationContentImage.h
// objective-octocat-notifications
//

#import <Cocoa/Cocoa.h>

/**
 * A class that represents a NSUserNotification content image for Objective Octocat Notifications.
 */
@interface OonNotificationContentImage : NSImage

/**
 * A method to get a background image to draw on.
 *
 * @return A OonNotificationContentImage background to draw on.
 */
+ (OonNotificationContentImage *)backgroundImageForSize:(NSSize)size;

/**
 * Get a OonNotificationContentImage from a NSURL.
 *
 * @param url The url to load and draw on top of our background.
 *
 * @return A OonNotificationContentImage to set for the notification content image.
 */
+ (OonNotificationContentImage *)imageFromURL:(NSURL *)url;

/**
 * Get a OonNotificationContentImage from an NSImage.
 *
 * @param image The NSImage to draw on our background.
 *
 * @return A OonNotificationContentImage to set for the notification content image.
 */
+ (OonNotificationContentImage *)imageFromImage:(NSImage *)image;

@end
