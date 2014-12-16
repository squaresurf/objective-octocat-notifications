// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubClientNoAuth.m
// objective-octocat-notifications
//

#import "constants.h"
#import "AFGithubClientNoAuth.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFGithubBaseURLString = @"https://api.github.com/";

@implementation AFGithubClientNoAuth

+ (void)checkForNewRelease
{
    NSUserNotificationCenter *defaultUserNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    NSArray *macNotifications = [defaultUserNotificationCenter deliveredNotifications];

    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [OonLog forLevel:OonLogDebug with:@"AppVersion: %@", appVersion];

    [[self sharedClient] getPath:@"repos/squaresurf/objective-octocat-notifications/tags" parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
        [OonLog forLevel:OonLogDebug with:@"Response when checking for new Release: %@", response];

        NSUserNotification *newVersionNotification = nil;
        for (NSUserNotification *notification in macNotifications) {
            NSNumber *notificationType = [[notification userInfo] valueForKey:@"type"];

            if ([notificationType unsignedLongValue] != OonMacNotificationForAppVersionCheck) {
                newVersionNotification = notification;
                break;
            }
        }

        if ([response count] > 0) {
            NSString *latestVersion = response[0][@"name"];
            [OonLog forLevel:OonLogDebug with:@"latestVersion: %@", latestVersion];
            if ([appVersion compare:latestVersion options:NSNumericSearch] == NSOrderedAscending) {
                if (newVersionNotification == nil) {
                    NSString *latestUrl = @"https://github.com/squaresurf/objective-octocat-notifications/releases/latest";

                    NSUserNotification *macNotification = [[NSUserNotification alloc] init];
                    macNotification.title = @"New Release!";
                    macNotification.informativeText = @"Click here to download the latest release of Objective Octocat Notifications.";
                    macNotification.userInfo = @{@"url": latestUrl, @"type": [NSNumber numberWithUnsignedLong:OonMacNotificationForAppVersionCheck]};
                    [defaultUserNotificationCenter deliverNotification:macNotification];
                }
            } else if (newVersionNotification != nil) {
                [defaultUserNotificationCenter removeDeliveredNotification:newVersionNotification];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id json) {
        [OonLog forLevel:OonLogError with:@"error: %@", json];
    }];

    // Check again in a day.
    [NSTimer scheduledTimerWithTimeInterval:kCheckForNewReleaseInterval
                                     target:self
                                   selector:@selector(checkForNewRelease)
                                   userInfo:nil
                                    repeats:NO];
}

+ (AFGithubClientNoAuth *)sharedClient {
    static AFGithubClientNoAuth *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFGithubClientNoAuth alloc] initWithBaseURL:[NSURL URLWithString:kAFGithubBaseURLString]];
    });

    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

	[self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

@end
