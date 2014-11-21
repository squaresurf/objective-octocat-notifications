// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// OonStatusBar.h
// objective-octocat-notifications
//

#import <Foundation/Foundation.h>
#import "OonIcon.h"

@interface OonStatusBarController : NSObject
{
    NSStatusItem *statusItem;
    OonIcon *defaultIcon;
    OonIcon *hasNotificationsIcon;
}

- (void) addTo:(NSMenu *)menu;

- (void) setActiveStateTo:(BOOL) hasNotifications;

- (void) setActiveStateFromNotificationsCount;

@end
