// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AppDelegate.h
// objective-octocat-notifications
//

#import <Cocoa/Cocoa.h>
#import "OonStatusBarController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>
{
    IBOutlet NSMenu *statusMenu;
}

/**
 * The key used to store in user defaults whether or not we've asked the user if we should add the app to the user login items.
 */
@property NSString *haveAskedIfWeShouldAddToLoginItemsDefaultsKey;

/**
 * The controller for the status bar menu.
 */
@property OonStatusBarController *statusItemController;

/**
 * This is a handler for url events such as the OAuth callback.
 */
 - (void)handleGetURLEvent: (NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

/**
 * Checks user defaults to know whether or not to ask if we should add the app to user login items. Then it will ask the user if we haven't already done so.
 *
 * @return User's answer or false if we've already asked the user.
 */
- (BOOL)shouldAddToLoginItems;

/**
 * Add this app to the user login items if shouldAddToLoginItems returns true.
 */
- (void)addToLoginItems;

@end
