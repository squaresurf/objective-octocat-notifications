// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// AFGithubOAuth.m
// objective-octocat-notifications
//

#import "AFGithubOAuth.h"
#import "AFJSONRequestOperation.h"
#import "AFGithubClient.h"
#import "GithubKeys.h"

static NSString * const kAFGithubOAuthBaseURL = @"https://github.com/login/oauth/";
static NSString * const kTokenScope = @"notifications,repo";

// Security
static NSMutableDictionary * AFKeychainQueryDictionaryWithIdentifier(NSString *identifier) {
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword, kSecClass, [[NSBundle mainBundle] bundleIdentifier], kSecAttrService, @"OAuth Token", (__bridge id)kSecAttrAccount, nil];

    return queryDictionary;
}

@implementation AFGithubOAuth

+ (AFGithubOAuth *)sharedClient {
    static AFGithubOAuth *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFGithubOAuth alloc] initWithBaseURL:[NSURL URLWithString:kAFGithubOAuthBaseURL]];
    });

    return _sharedClient;
}

+ (void)clearToken {
    [[self sharedClient] setValue:nil forKey:@"token"];
    [[self sharedClient] keychainDeleteToken];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    // Set up the keychain query dictionary.
    self.keychainQueryDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword, kSecClass, [[NSString alloc] initWithFormat:@"%@ scope:%@", [[NSBundle mainBundle] bundleIdentifier], kTokenScope ], kSecAttrService, @"OAuth Token", (__bridge id)kSecAttrAccount, nil];

    // Set up a random state string
    int length = 64;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];

    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    self.state = randomString;

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];

    return self;
}

- (NSString *)getToken {
    if ([self token] == nil) {
        #if defined(GITHUB_TOKEN)
            self.token = GITHUB_TOKEN;
        #else
            NSString *token = [self keychainRetrieveToken];
            if (token == nil) {
                #if defined(GITHUB_CLIENT_ID) && defined(GITHUB_CLIENT_SECRET)
                    // Start OAuth2
                    NSURL *oauthUrl = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@authorize?client_id=%@&scope=%@&state=%@", kAFGithubOAuthBaseURL, GITHUB_CLIENT_ID, kTokenScope, [self state]]];
                    if( ![[NSWorkspace sharedWorkspace] openURL:oauthUrl] ) {
                        NSLog(@"Failed to open url: %@",[oauthUrl description]);
                    }
                #else
                    #error @"Missing GITHUB_TOKEN or GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET. Please read the authentication section of the README."
                #endif
            } else {
                self.token = token;
            }

#endif
    }

    return [self token];
}

- (void)oauthCallbackWith:(NSURL *)url {
    NSString *query = [url query];
    NSString *state = [query substringWithRange:[[[NSRegularExpression regularExpressionWithPattern:@"state=([^&=]*)" options:0 error:nil] firstMatchInString:query options:0 range:NSMakeRange(0, [query length])] rangeAtIndex:1]];

    if (![state isEqualToString:[self state]]) {
        NSLog(@"OAuth state doesn't match. Can't continue.");
        return;
    }

    #if defined(GITHUB_CLIENT_ID) && defined(GITHUB_CLIENT_SECRET)
        NSString *code = [query substringWithRange:[[[NSRegularExpression regularExpressionWithPattern:@"code=([^&=]*)" options:0 error:nil] firstMatchInString:query options:0 range:NSMakeRange(0, [query length])] rangeAtIndex:1]];

        [self getPath:@"access_token" parameters:@{@"client_id" : GITHUB_CLIENT_ID, @"client_secret" : GITHUB_CLIENT_SECRET, @"code" : code} success:^(AFHTTPRequestOperation *operation, id json) {
            self.token = json[@"access_token"];
            [self keychainStoreToken];
            [AFGithubClient startNotifications];
        } failure:nil];
    #endif
}

// Security
- (BOOL)keychainStoreToken {
    NSMutableDictionary *queryDictionary = [[self keychainQueryDictionary] mutableCopy];

    if (![self token]) {
        return [self keychainDeleteToken];
    }

    NSDictionary *updateDictionary = @{(__bridge id)kSecValueData : [[self token] dataUsingEncoding:NSUTF8StringEncoding]};

    OSStatus status;
    BOOL exists = ([self keychainRetrieveToken] != nil);

    if (exists) {
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
    } else {
        [queryDictionary addEntriesFromDictionary:updateDictionary];
        status = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, NULL);
    }

    if (status != errSecSuccess) {
        NSLog(@"Unable to store OAuth Token in Keychain.");
    }

    return (status == errSecSuccess);
}

- (NSString *)keychainRetrieveToken {
    NSMutableDictionary *queryDictionary = [[self keychainQueryDictionary] mutableCopy];
    [queryDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [queryDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];

    CFDataRef result = nil;

    if (SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&result) != errSecSuccess) {
        NSLog(@"Unable to fetch OAuth Token in Keychain.");
        return nil;
    }

    return [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];
}

- (BOOL)keychainDeleteToken {
    NSMutableDictionary *queryDictionary = [[self keychainQueryDictionary] mutableCopy];
    [queryDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnRef];

    SecKeychainItemRef item = nil;

    if (SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&item) != errSecSuccess) {
        NSLog(@"Unable to find OAuth Token in Keychain for deletion.");
        return NO;
    }

    OSStatus status = SecKeychainItemDelete(item);

    if (status != errSecSuccess) {
        NSLog(@"Unable to delete OAuth Token in Keychain.");
    }

    return (status == errSecSuccess);
}

@end
