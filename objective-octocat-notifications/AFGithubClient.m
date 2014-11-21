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

static NSString * const kAFGithubBaseURLString = @"https://api.github.com/";
static NSString * const kOAuthBaseUrl = @"https://github.com/login/oauth/";
static float      const kPollInterval = 60.0;

@implementation AFGithubClient

+ (void)startNotifications {
    NSString *token = [[AFGithubOAuth sharedClient] getToken];

    if (token == nil) {
        return;
    }

    [[AFGithubClient sharedClient] setDefaultHeader:@"Authorization" value:[[NSString alloc] initWithFormat:@"token %@", token]];
    [[AFGithubClient sharedClient] checkForNewRelease];
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

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

	[self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

- (void)checkForNewRelease
{
    NSString *tags = @"repos/squaresurf/objective-octocat-notifications/tags";

    [[AFGithubClient sharedClient] getPath:tags parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
        if ([response count] > 0) {
            NSString *latestVersion = response[0][@"name"];
            if ([kAppVersion compare:latestVersion options:NSNumericSearch] == NSOrderedAscending) {
                NSString *latestUrl = [NSString stringWithFormat:@"https://github.com/squaresurf/objective-octocat-notifications/releases/%@", latestVersion];

                NSUserNotification *macNotification = [[NSUserNotification alloc] init];
                macNotification.title = @"New Release!";
                macNotification.informativeText = @"Click here to download the latest release of Objective Octocat Notifications.";
                macNotification.userInfo = @{@"url": latestUrl};
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:macNotification];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id json) {
        NSLog(@"error: %@", json);
    }];


    // Check again in a day.
    [NSTimer scheduledTimerWithTimeInterval:60 * 60 * 24
                                     target:self
                                   selector:@selector(checkForNewRelease)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)getNotifications
{
    AppDelegate *appDelegate = [NSApp delegate];

    NSUserNotificationCenter *defaultUserNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    NSArray *macNotifications = [defaultUserNotificationCenter deliveredNotifications];

    [[AFGithubClient sharedClient] getPath:@"notifications" parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
        NSMutableDictionary *activeNotifications = [[NSMutableDictionary alloc] init];

        for (NSUserNotification *notification in macNotifications) {
            bool removeNotification = YES;
            NSString *notificationId = [[notification userInfo] valueForKey:@"id"];
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
            appDelegate.menubarController.statusItemView.hasNotifications = YES;

            // Create a block operations queue since we have to call another api to get the correct html url for the notification click.
            NSBlockOperation *macNotificationQueue = [NSBlockOperation blockOperationWithBlock:^(){}];

            for (id notification in response) {
                if ([activeNotifications objectForKey:notification[@"id"]] == Nil) {
                    [macNotificationQueue addExecutionBlock:^(){
                        [[AFGithubClient sharedClient] getPath:notification[@"subject"][@"latest_comment_url"] parameters:@{} success:^(AFHTTPRequestOperation *operation, id response) {
                            NSString *url = response[@"html_url"];
                            
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                            NSDate *notificationDate = [dateFormatter dateFromString:notification[@"updated_at"]];
                            
                            NSUserNotification *macNotification = [[NSUserNotification alloc] init];
                            macNotification.title = notification[@"subject"][@"type"];
                            macNotification.subtitle = notification[@"repository"][@"full_name"];
                            macNotification.informativeText = notification[@"subject"][@"title"];
                            macNotification.userInfo = @{@"id": notification[@"id"], @"url": url};
                            macNotification.deliveryDate = notificationDate;
                            [defaultUserNotificationCenter deliverNotification:macNotification];
                            
                        } failure:^(AFHTTPRequestOperation *operation, id json) {
                            // Just log the error since we'll try again in a little bit.
                            NSLog(@"error getting html url for mac notification: %@", json);
                        }];
                    }];
                }
            }
            [macNotificationQueue start];
        }
        

        float max_poll_interval = [[[operation response] allHeaderFields][@"X-Poll-Interval"] floatValue];
        float poll = (max_poll_interval > kPollInterval) ? max_poll_interval : kPollInterval;
        [self setTimerWithPoll:poll];
    } failure:^(AFHTTPRequestOperation *operation, id json) {
        if ([operation.response statusCode] == 401) {
            [AFGithubOAuth clearToken];
            [AFGithubClient startNotifications];
        } else {
            NSLog(@"error: %@", json);
            [self setTimerWithPoll:kPollInterval];
        }
    }];
    
    if ([[defaultUserNotificationCenter deliveredNotifications] count] == 0) {
        appDelegate.menubarController.statusItemView.hasNotifications = NO;
    }
}

- (void)setTimerWithPoll:(float)poll {
//    NSLog(@"Going to check for more notifications in %f seconds.", poll);
    [NSTimer scheduledTimerWithTimeInterval:poll
                                     target:self
                                   selector:@selector(getNotifications)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)activatedNotification:(NSUserNotification *) notification {
    NSURL *oauthUrl = [NSURL URLWithString:notification.userInfo[@"url"]];
    if( ![[NSWorkspace sharedWorkspace] openURL:oauthUrl] ) {
        NSLog(@"Failed to open url: %@",[oauthUrl description]);
    }
}

@end
