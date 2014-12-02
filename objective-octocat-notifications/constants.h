// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
//  constants.h
//  objective-octocat-notifications
//

#import "OonLog.h"

typedef enum : NSUInteger {
    OonMacNotificationForGithubNotification = 1,
    OonMacNotificationForAppVersionCheck,
} OonMacNotificationType;

#define kAppVersion @"0.3.0"
#define kOonLogLevel OonLogDebug

#define kCheckForNewReleaseInterval 60 * 60 * 24
#define kMarkNotificationsAsViewedOnClick 1