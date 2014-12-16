// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubOAuth.h
// objective-octocat-notifications
//

#import "AFHTTPClient.h"
#import <Security/Security.h>

/**
 * A subclass of AFHTTPClient for getting an OAuth token from Github.
 */
@interface AFGithubOAuth : AFHTTPClient

/**
 * A randomly generated state string for use with an OAuth call.
 */
@property (strong) NSString *state;

/**
 * The OAuth token in memory.
 */
@property (strong) NSString *token;

/**
 * A keychain query dictionary to search, store, or delete with.
 */
@property (strong) NSDictionary *keychainQueryDictionary;

/**
 * Sets up a shared client for making Github API calls.
 *
 * @return A singleton instance for AFGithubOauth.
 */
+ (AFGithubOAuth *)sharedClient;

/**
 * Clear the current OAuth token from memory and the keychain.
 */
+ (void)clearToken;

/**
 * Get an OAuth token. Either via the Github_TOKEN constant or the Github OAuth protocol.
 *
 * @return The token.
 */
- (NSString *)getToken;

/**
 * Handle the OAuth callback from Github once the app has been authorized.
 */
- (void)oauthCallbackWith:(NSURL *)url;

/**
 * Store in the keychain the current token from memory.
 *
 * @return Whether or not the storage was successful.
 */
- (BOOL)keychainStoreToken;

/**
 * Retrieve the token from the keychain.
 *
 * @return The stored OAuth token.
 */
- (NSString *)keychainRetrieveToken;

/**
 * Delete the stored token from the keychain.
 *
 * @return Whether or not the deletion was successful.
 */
- (BOOL)keychainDeleteToken;

@end
