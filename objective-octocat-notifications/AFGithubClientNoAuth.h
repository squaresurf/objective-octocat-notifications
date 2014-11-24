// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubClientNoAuth.h
// objective-octocat-notifications
//

#import "AFHTTPClient.h"

@interface AFGithubClientNoAuth : AFHTTPClient

+ (void)checkForNewRelease;

+ (AFGithubClientNoAuth *)sharedClient;

@end
