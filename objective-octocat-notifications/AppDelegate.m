// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AppDelegate.m
// objective-octocat-notifications
//

#import "AppDelegate.h"
#import "AFGithubClientNoAuth.h"
#import "AFGithubClient.h"
#import "AFGithubOAuth.h"
#import "OonIcon.h"
#import "OonLog.h"

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
    _haveAskedIfWeShouldAddToLoginItemsDefaultsKey = [NSString stringWithFormat:@"%@.haveAskedIfWeShouldAddToLoginItems", [[NSRunningApplication currentApplication] bundleIdentifier]];

    [self addToLoginItems];
    [AFGithubClientNoAuth checkForNewRelease];
    [AFGithubClient startNotifications];
}

- (void) awakeFromNib {
    [_statusItemController addTo:statusMenu];
}

#pragma mark -

- (void) handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];

    if ([[url host] caseInsensitiveCompare:@"oauthCallback"] == NSOrderedSame) {
        [[AFGithubOAuth sharedClient] oauthCallbackWith:url];
    } else {
        [OonLog forLevel:OonLogWarn with:@"Don't know what to do with this url: %@", url];
    }
}

- (BOOL)shouldAddToLoginItems {
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Uncomment to test new install workflow.
    // [defaults removeObjectForKey:_haveAskedIfWeShouldAddToLoginItemsDefaultsKey];

    if ([defaults boolForKey:_haveAskedIfWeShouldAddToLoginItemsDefaultsKey]) {
        return false;
    }

    CFDictionaryRef dialogOptions = (__bridge CFDictionaryRef)@{
                                                                (__bridge NSString *)kCFUserNotificationAlertHeaderKey: @"Objective Octocat Notifications",
                                                                (__bridge NSString *)kCFUserNotificationAlertMessageKey:
                                                                    @"Would you like Objective Octocat Notifications to start on login?",
                                                                (__bridge NSString *)kCFUserNotificationDefaultButtonTitleKey: @"No",
                                                                (__bridge NSString *)kCFUserNotificationAlternateButtonTitleKey: @"Yes"};

    CFUserNotificationRef dialog = CFUserNotificationCreate(kCFAllocatorDefault, 0, kCFUserNotificationNoteAlertLevel, NULL, dialogOptions);

    CFOptionFlags shouldEnableLoginStart;
    CFUserNotificationReceiveResponse(dialog, 0, &shouldEnableLoginStart);
    [OonLog forLevel:OonLogDebug with:@"state: %lu", shouldEnableLoginStart];

    [defaults setBool:true forKey:_haveAskedIfWeShouldAddToLoginItemsDefaultsKey];

    return shouldEnableLoginStart == 1;
}

- (void)addToLoginItems {
    if (![self shouldAddToLoginItems]) {
        return;
    }

    LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL), kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)[[NSBundle mainBundle] bundleURL], NULL, NULL);

    if (item) {
        CFRelease(item);
    }
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [center removeDeliveredNotification:notification];
    [_statusItemController setActiveStateFromNotificationsCount];

    if (kMarkNotificationsAsViewedOnClick && [notification.userInfo[@"type"] unsignedLongValue] == OonMacNotificationForGithubNotification) {
        [AFGithubClient markAsViewed:notification.userInfo[@"id"]];
    }

    NSURL *url = [NSURL URLWithString:notification.userInfo[@"url"]];
    if( ![[NSWorkspace sharedWorkspace] openURL:url] ) {
        [OonLog forLevel:OonLogError with:@"Failed to open url: %@",[url description]];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    // Always display notifications when asked.
    return YES;
}

@end
