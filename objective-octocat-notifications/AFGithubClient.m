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
static NSString * const kAppVersion = @"0.1.1";

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
            if (![kAppVersion isEqualToString:latestVersion]) {
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
}

- (void)getNotifications
{
    AppDelegate *appDelegate = [NSApp delegate];

    if ([[[NSUserNotificationCenter defaultUserNotificationCenter] deliveredNotifications] count] == 0) {
        appDelegate.menubarController.statusItemView.hasNotifications = NO;
    }

    NSDictionary *params = @{};
    if (self.since_date) {
        params = @{@"since":self.since_date};
    }
    
    [[AFGithubClient sharedClient] getPath:@"notifications" parameters:params success:^(AFHTTPRequestOperation *operation, id response) {
        if ([response count] > 0) {
            appDelegate.menubarController.statusItemView.hasNotifications = YES;

            BOOL first = YES;
            for (id notification in response) {
                if (first) {
                    first = NO;
                    self.since_date = notification[@"updated_at"];
                }
                
                NSString *url = notification[@"subject"][@"url"];
                url = [url stringByReplacingOccurrencesOfString:@"api.github.com" withString:@"github.com"];
                url = [url stringByReplacingOccurrencesOfString:@"/pulls/" withString:@"/pull/"];
                url = [url stringByReplacingOccurrencesOfString:@"/repos/" withString:@"/"];
                
                NSUserNotification *macNotification = [[NSUserNotification alloc] init];
                macNotification.title = notification[@"subject"][@"type"];
                macNotification.informativeText = notification[@"subject"][@"title"];
                macNotification.userInfo = @{@"id": notification[@"id"], @"url": url};
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:macNotification];
            }
        }

        float max_poll_interval = [[[operation response] allHeaderFields][@"X-Poll-Interval"] floatValue];
        float poll = (max_poll_interval > kPollInterval) ? max_poll_interval : kPollInterval;
        [self setTimerWithPoll:poll];
    } failure:^(AFHTTPRequestOperation *operation, id json) {
        NSLog(@"error: %@", json);
        [self setTimerWithPoll:kPollInterval];
    }];
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
    NSLog(@"user info: %@", notification.userInfo);
    
    NSURL *oauthUrl = [NSURL URLWithString:notification.userInfo[@"url"]];
    if( ![[NSWorkspace sharedWorkspace] openURL:oauthUrl] ) {
        NSLog(@"Failed to open url: %@",[oauthUrl description]);
    }
}

@end
