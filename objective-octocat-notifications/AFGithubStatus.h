// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubStatus.m
// objective-octocat-notifications
//

#import "AFHTTPClient.h"

/**
 * A class to get the Github status from the status api.
 */
@interface AFGithubStatus : AFHTTPClient

/**
 * A key for the user defaults dictionary to store the last status message's date.
 */
@property NSString *lastStatusMessageDateDefaultsKey;

/**
 * Sets up a shared client for making github status API calls.
 *
 * @return A singleton instance for AFGithubStatus
 */
+ (AFGithubStatus *)sharedClient;

/**
 * Check the status api to see if there is a new state.
 */
- (void)check;

/**
 * This will set a timer to check the status again after a specified amount of time.
 *
 * @param poll The amount of time to wait before checking again.
 */
- (void)setTimerWithPoll:(float) poll;

@end
