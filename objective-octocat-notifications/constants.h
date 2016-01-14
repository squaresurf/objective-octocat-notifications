// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
//  constants.h
//  objective-octocat-notifications
//

// This sets up constants for use throughout the app.

#import "OonLog.h"

// Setup a global notification type enum to be used for Github user notifications, app version checks, and Github status notifications.
typedef enum : NSUInteger {
    OonMacNotificationForGithubNotification = 1,
    OonMacNotificationForAppVersionCheck,
    OonMacNotificationForGithubStatus,
    OonMacNotificationForGithubNotificationCount,
} OonMacNotificationType;

// The severity of log messages to log.
#define kOonLogLevel OonLogWarn

// How often should we check for new releases? (Set in seconds)
#define kCheckForNewReleaseInterval 60 * 60 * 24

// The optimistic amount of time between github and github status api calls.
#define kPollInterval 60.0

// Whether or not notifications should be marked via the API when clicked.
#define kMarkNotificationsAsViewedOnClick 1

// The max number of Mac notifications before we just post a single notification with a count that will take the user to the Github notifications page.
#define kMaxMacNotifications 20

// The max number of Github notifications they will return from their api.
#define kMaxGithubNotificationsReturned 50