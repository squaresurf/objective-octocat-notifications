// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubOAuth.h
// objective-octocat-notifications
//

#import "AFHTTPClient.h"
#import <Security/Security.h>


@interface AFGithubOAuth : AFHTTPClient

+ (AFGithubOAuth *)sharedClient;

+ (void)clearToken;

- (NSString *)getToken;

- (void)oauthCallbackWith:(NSURL *)url;

- (BOOL)keychainStoreToken;

- (NSString *)keychainRetrieveToken;

- (BOOL)keychainDeleteToken;

@property (strong) NSString *state;
@property (strong) NSString *token;
@property (strong) NSDictionary *keychainQueryDictionary;

@end
