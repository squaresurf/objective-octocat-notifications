// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// OonStatusBar.h
// objective-octocat-notifications
//

#import <Foundation/Foundation.h>
#import "OonIcon.h"

/**
 * Controller for the app's status bar item.
 */
@interface OonStatusBarController : NSObject
{
    NSStatusItem *statusItem;
    OonIcon *defaultIcon;
    OonIcon *hasNotificationsIcon;
}

/**
 * Add's the app's status bar item to the main status bar menu.
 *
 * @param menu The menu for which to add the status bar item.
 */
- (void) addTo:(NSMenu *)menu;

/**
 * Sets the status bar icon to the defaultIcon or the hasNotificationsIcon.
 *
 * @param hasNotifications Whether or not the icon should indicate that there are notifications.
 */
- (void) setActiveStateTo:(BOOL) hasNotifications;

/**
 * Will count the visible notifications to determine if the icon should be the defaultIcon or the hasNotificationsIcon.
 */
- (void) setActiveStateFromNotificationsCount;

@end
