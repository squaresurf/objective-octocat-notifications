// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubClientNoAuth.h
// objective-octocat-notifications
//

#import "AFHTTPClient.h"

/**
 * A subclass of AFHTTPClient for making unauthorized API calls to Github.
 */
@interface AFGithubClientNoAuth : AFHTTPClient

/**
 * Check the squaresurf/objective-octocat-notifications repo on Github to see if there are any new releases to notify the user about.
 */
+ (void)checkForNewRelease;

/**
 * Sets up a shared client for making github API calls.
 *
 * @return A singleton instance for AFGithubClientNoAuth.
 */
+ (AFGithubClientNoAuth *)sharedClient;

@end
