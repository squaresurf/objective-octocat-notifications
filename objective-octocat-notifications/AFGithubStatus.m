// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubStatus.m
// objective-octocat-notifications
//

#import "constants.h"
#import "AFGithubStatus.h"
#import "AFJSONRequestOperation.h"
#import "AppDelegate.h"
#import "OonLog.h"
#import "OonNotificationContentImage.h"

static NSString * const kAFGithubStatusBaseURLString = @"https://www.githubstatus.com/";

@implementation AFGithubStatus

+ (AFGithubStatus *)sharedClient {
    static AFGithubStatus *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFGithubStatus alloc] initWithBaseURL:[NSURL URLWithString:kAFGithubStatusBaseURLString]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    _lastStatusMessageDateDefaultsKey = [NSString stringWithFormat:@"%@.lastStatusMessageDate", [[NSRunningApplication currentApplication] bundleIdentifier]];

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    [self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

#pragma mark -

- (void)check
{
    [self getPath:@"api/v2/status.json" parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
        [NSUserDefaults resetStandardUserDefaults];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        // Uncomment to test new install workflow.
        // [defaults removeObjectForKey:self->_lastStatusMessageDateDefaultsKey];

        NSString *lastStatusMessageDate = [defaults stringForKey:self->_lastStatusMessageDateDefaultsKey];

        if (lastStatusMessageDate && NSOrderedSame == [lastStatusMessageDate compare:response[@"page"][@"updated_at"]]) {
            [OonLog forLevel:OonLogDebug with:@"We've already shown the status, so nothing to do here."];
            [self setTimerWithPoll:kPollInterval];
            return;
        }

        AppDelegate *appDelegate = (AppDelegate *) [NSApp delegate];
        [appDelegate.statusItemController setActiveStateTo:YES];

        NSUserNotificationCenter *defaultUserNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        for (NSUserNotification *notification in [defaultUserNotificationCenter deliveredNotifications]) {
            if ([[[notification userInfo] valueForKey:@"type"] unsignedLongValue] == OonMacNotificationForGithubStatus) {
                [defaultUserNotificationCenter removeDeliveredNotification:notification];
            }
        }

        [OonLog forLevel:OonLogDebug with:@"Last Github Status Message: %@", response];

        NSUserNotification *macNotification = [[NSUserNotification alloc] init];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *notificationDate = [dateFormatter dateFromString:response[@"page"][@"updated_at"]];

        NSString *imageStatus = @"major"; // major and critical statuses
        if ([response[@"status"][@"indicator"] isEqualToString:@"none"]) {
            imageStatus = @"good";
        }
        if ([response[@"status"][@"indicator"] isEqualToString:@"minor"]) {
            imageStatus = @"minor";
        }

        macNotification.contentImage = [NSImage imageNamed:[NSString stringWithFormat:@"status-icon-%@.png", imageStatus]];
        macNotification.title = @"Github Status";
        macNotification.informativeText = response[@"status"][@"description"];
        macNotification.userInfo = @{@"url": response[@"page"][@"url"], @"type": [NSNumber numberWithUnsignedLong:OonMacNotificationForGithubStatus]};
        macNotification.deliveryDate = notificationDate;
        [defaultUserNotificationCenter deliverNotification:macNotification];

        // Save the date of the last status we received so we don't show it again.
        [defaults setObject:response[@"page"][@"updated_at"] forKey:self->_lastStatusMessageDateDefaultsKey];

        [self setTimerWithPoll:kPollInterval];
    } failure:^(AFHTTPRequestOperation *operation, id json) {
        [OonLog forLevel:OonLogError with:@"error: %@", json];
        [self setTimerWithPoll:kPollInterval];
    }];
}

- (void)setTimerWithPoll:(float)poll {
    [OonLog forLevel:OonLogDebug with:@"Going to check Github Status again in %f seconds.", poll];
    [NSTimer scheduledTimerWithTimeInterval:poll
                                     target:self
                                   selector:@selector(check)
                                   userInfo:nil
                                    repeats:NO];
}

@end
