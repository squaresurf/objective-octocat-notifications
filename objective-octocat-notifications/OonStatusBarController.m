// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// OonStatusBar.m
// objective-octocat-notifications
//

#import "OonStatusBarController.h"
#import "OonIcon.h"

@implementation OonStatusBarController

- (id)init
{
    self = [super init];
    if (self) {
        defaultIcon = [OonIcon forStatusBarFrom:OonIconStatusBarDefault];
        defaultDarkIcon = [OonIcon forStatusBarFrom:OonIconStatusBarActive];
        hasNotificationsIcon = [OonIcon forStatusBarFrom:OonIconStatusBarHasNotifications];
        statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    }
    return self;
}

- (void) addTo:(NSMenu *)menu
{
    [self setActiveStateFromNotificationsCount];
    [statusItem setMenu:menu];
    [statusItem setAlternateImage:[OonIcon forStatusBarFrom:OonIconStatusBarActive]];
    [statusItem setHighlightMode:YES];
}

- (void) setActiveStateTo:(BOOL) hasNotifications
{
    if (hasNotifications) {
        [statusItem setImage:hasNotificationsIcon];
    } else {
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqualToString:@"Dark"]) {
            [statusItem setImage:defaultDarkIcon];
        } else {
            [statusItem setImage:defaultIcon];
        }
    }
}

- (void) setActiveStateFromNotificationsCount
{
    bool currentlyHasNotifications = 0 < [[[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications] count];
    [self setActiveStateTo:currentlyHasNotifications];
}

@end
