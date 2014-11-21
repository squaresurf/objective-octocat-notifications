// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AppDelegate.m
// objective-octocat-notifications
//

#import "AppDelegate.h"
#import "AFGithubClient.h"
#import "AFGithubOAuth.h"
#import "OonIcon.h"

@implementation AppDelegate
@class AFHTTPRequestOperation;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        _statusItemController = [[OonStatusBarController alloc] init];
    }
    return self;
}

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0
                                                            diskCapacity:0
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // This calls objective-octocat-notifications:// uri scheme handler
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSUserNotification *userNotification = [notification.userInfo objectForKey:@"NSApplicationLaunchUserNotificationKey"];
    if (userNotification) {
        [self userNotificationCenter:[NSUserNotificationCenter defaultUserNotificationCenter] didActivateNotification:userNotification];
    }
    [AFGithubClient startNotifications];
}

- (void) awakeFromNib {
    [_statusItemController addTo:statusMenu];
}

- (void) handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];

    if ([[url host] caseInsensitiveCompare:@"oauthCallback"] == NSOrderedSame) {
        [[AFGithubOAuth sharedClient] oauthCallbackWith:url];
    } else {
        NSLog(@"Don't know what to do with this url: %@", url);
    }
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [center removeDeliveredNotification:notification];
    [_statusItemController setActiveStateFromNotificationsCount];
    [[AFGithubClient sharedClient] activatedNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    // Always display notifications when asked.
    return YES;
}

@end
