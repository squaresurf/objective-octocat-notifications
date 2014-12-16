// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// OonIcon.h
// objective-octocat-notifications
//

#import <Foundation/Foundation.h>

/**
 * An enum that represents the context with which the icon is used.
 */
typedef NS_ENUM(NSInteger, OonIconType) {
    OonIconStatusBarDefault,
    OonIconStatusBarActive,
    OonIconStatusBarHasNotifications
};

/**
 * A class that represents the icon for Objective Octocat Notifications.
 */
@interface OonIcon : NSImage

/**
 * Setup a OonIcon that can be used for the status bar.
 *
 * @param type The icon type that to be returned.
 *
 * @return An icon for use with the status bar.
 */
+ (OonIcon *)forStatusBarFrom:(OonIconType) type;

@end