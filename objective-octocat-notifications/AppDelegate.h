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

@property OonStatusBarController *statusItemController;

- (void)handleGetURLEvent: (NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

@end
