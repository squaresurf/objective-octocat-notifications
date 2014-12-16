// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
//  constants.h
//  objective-octocat-notifications
//

// This sets up constants for use throughout the app.

#import "OonLog.h"

// Setup a global notification type enum to be used for Github user notifications or app version checks.
typedef enum : NSUInteger {
    OonMacNotificationForGithubNotification = 1,
    OonMacNotificationForAppVersionCheck,
} OonMacNotificationType;

// The current version of the app.
#define kAppVersion @"0.3.0"

// The severity of log messages to log.
#define kOonLogLevel OonLogDebug

// How often should we check for new releases? (Set in seconds)
#define kCheckForNewReleaseInterval 60 * 60 * 24

// Whether or not notifications should be marked via the API when clicked.
#define kMarkNotificationsAsViewedOnClick 1