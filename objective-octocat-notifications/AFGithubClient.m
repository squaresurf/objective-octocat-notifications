// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubClient.m
// objective-octocat-notifications
//

#import "AFGithubClient.h"
#import "AFJSONRequestOperation.h"
#import "AFGithubOAuth.h"
#import "AppDelegate.h"
#import "OonNotificationContentImage.h"

static NSString * const kAFGithubBaseURLString = @"https://api.github.com/";
static float      const kPollInterval = 60.0;

@implementation AFGithubClient

+ (void)startNotifications {
    NSString *token = [[AFGithubOAuth sharedClient] getToken];

    if (token == nil) {
        return;
    }

    [[AFGithubClient sharedClient] setDefaultHeader:@"Authorization" value:[[NSString alloc] initWithFormat:@"token %@", token]];
    [[AFGithubClient sharedClient] getNotifications];
}

+ (AFGithubClient *)sharedClient {
    static AFGithubClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFGithubClient alloc] initWithBaseURL:[NSURL URLWithString:kAFGithubBaseURLString]];
    });

    return _sharedClient;
}

+ (void)markAsViewed:(NSString *)notificationId {
    NSString *path = [NSString stringWithFormat:@"notifications/threads/%@", notificationId];
    [[AFGithubClient sharedClient] patchPath:path parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
        [OonLog forLevel:OonLogDebug with:@"Marked %@ as read.", notificationId];
    } failure:^(AFHTTPRequestOperation *operation, id json) {
        [OonLog forLevel:OonLogError with:@"Couldn't mark %@ as read.", notificationId];
    }];
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

- (void)getNotifications
{
    AppDelegate *appDelegate = (AppDelegate *) [NSApp delegate];

    NSUserNotificationCenter *defaultUserNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    NSArray *macNotifications = [defaultUserNotificationCenter deliveredNotifications];

    [[AFGithubClient sharedClient] getPath:@"notifications" parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
        [OonLog forLevel:OonLogDebug with:@"Got response from notifications:\n%@", response];

        NSMutableDictionary *activeNotifications = [[NSMutableDictionary alloc] init];

        for (NSUserNotification *notification in macNotifications) {
            bool removeNotification = YES;
            NSString *notificationId = [[notification userInfo] valueForKey:@"id"];
            NSNumber *notificationType = [[notification userInfo] valueForKey:@"type"];

            if ([notificationType unsignedLongValue] != OonMacNotificationForGithubNotification) {
                continue;
            }

            for (id githubNotification in response) {
                if ([notificationId compare:githubNotification[@"id"]] == NSOrderedSame) {
                    removeNotification = NO;
                    break;
                }
            }

            if (removeNotification) {
                [defaultUserNotificationCenter removeDeliveredNotification:notification];
            } else {
                [activeNotifications setObject:notification forKey:notificationId];
            }
        }

        if ([response count] > 0) {
            [appDelegate.statusItemController setActiveStateTo:YES];

            // Create a block operations queue since we have to call another api to get the correct html url for the notification click.
            NSBlockOperation *macNotificationQueue = [NSBlockOperation blockOperationWithBlock:^(){}];

            for (id notification in response) {
                if ([activeNotifications objectForKey:notification[@"id"]] == Nil) {
                    [macNotificationQueue addExecutionBlock:^(){
                        [[AFGithubClient sharedClient] getPath:notification[@"subject"][@"latest_comment_url"] parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
                            [OonLog forLevel:OonLogDebug with:@"response from %@:\n%@", notification[@"subject"][@"latest_comment_url"], response];
                            NSString *url = response[@"html_url"];

                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                            NSDate *notificationDate = [dateFormatter dateFromString:notification[@"updated_at"]];

                            NSUserNotification *macNotification = [[NSUserNotification alloc] init];

                            macNotification.contentImage = [OonNotificationContentImage imageFromURL:[NSURL URLWithString:notification[@"repository"][@"owner"][@"avatar_url"]]];
                            macNotification.title = notification[@"subject"][@"type"];
                            macNotification.subtitle = notification[@"repository"][@"full_name"];
                            macNotification.informativeText = notification[@"subject"][@"title"];
                            macNotification.userInfo = @{@"id": notification[@"id"], @"url": url, @"type": [NSNumber numberWithUnsignedLong:OonMacNotificationForGithubNotification]};
                            macNotification.deliveryDate = notificationDate;
                            [defaultUserNotificationCenter deliverNotification:macNotification];

                        } failure:^(AFHTTPRequestOperation *operation, id json) {
                            // Without access to a private repo we will just get a 404 response.
                            if ([operation.response statusCode] == 401 || [operation.response statusCode] == 404) {
                                [AFGithubOAuth clearToken];
                                [AFGithubClient startNotifications];
                            } else {
                                // Just log the error since we'll try again in a little bit.
                                [OonLog forLevel:OonLogError with:@"error getting html url for mac notification: %@", json];
                            }
                        }];
                    }];
                }
            }
            [macNotificationQueue start];
        } else if ([[defaultUserNotificationCenter deliveredNotifications] count] == 0) {
            [appDelegate.statusItemController setActiveStateTo:NO];
        }


        float max_poll_interval = [[[operation response] allHeaderFields][@"X-Poll-Interval"] floatValue];
        float poll = (max_poll_interval > kPollInterval) ? max_poll_interval : kPollInterval;
        [self setTimerWithPoll:poll];
    } failure:^(AFHTTPRequestOperation *operation, id json) {
        if ([operation.response statusCode] == 401) {
            [AFGithubOAuth clearToken];
            [AFGithubClient startNotifications];
        } else {
            [OonLog forLevel:OonLogError with:@"error: %@", json];
            [self setTimerWithPoll:kPollInterval];
        }
    }];
}

- (void)setTimerWithPoll:(float)poll {
    [OonLog forLevel:OonLogDebug with:@"Going to check for more notifications in %f seconds.", poll];
    [NSTimer scheduledTimerWithTimeInterval:poll
                                     target:self
                                   selector:@selector(getNotifications)
                                   userInfo:nil
                                    repeats:NO];
}

@end
