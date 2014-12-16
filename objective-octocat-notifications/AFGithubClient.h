// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubClient.h
// objective-octocat-notifications
//

#import "AFHTTPClient.h"

/**
 * A subclass of AFHTTPClient for making authorized API calls to Github.
 */
@interface AFGithubClient : AFHTTPClient

/**
 * Start the loop that gets notifications. This will ask for an OAuth token and return nil if it can't get a token. Otherwise set the token as a default http header for the sharedClient, then call getNotifications with the sharedClient
 */
+ (void)startNotifications;

/**
 * Sets up a shared client for making Github API calls.
 *
 * @return A singleton instance for AFGithubClient.
 */
+ (AFGithubClient *)sharedClient;

/**
 * Will mark a Github notification as viewed.
 *
 * @param notificationId The notification thread id that should be marked as viewed.
 */
+ (void)markAsViewed:(NSString *)notificationId;

/**
 * Query the Github API for notifications and display them if any new notifications are returned. If no errors are encountered, this will call the setTimerWithPoll function to continue the notifications loop started with startNotifications.
 */
- (void)getNotifications;

/**
 * This will set a timer to call getNotifications after a specified amount of time.
 *
 * @param poll The amount of time to wait before polling the Github notifications API.
 */
- (void)setTimerWithPoll:(float) poll;

@end
