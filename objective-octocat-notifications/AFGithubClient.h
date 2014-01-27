// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubClient.h
// objective-octocat-notifications
//

#import "AFHTTPClient.h"

@interface AFGithubClient : AFHTTPClient

+ (void)startNotifications;

+ (AFGithubClient *)sharedClient;

- (void)getNotifications;

- (void)setTimerWithPoll:(float) poll;

- (void)activatedNotification:(NSUserNotification *) notification;

@property (strong) NSString *state;
@property (strong) NSString *since_date;

@end
