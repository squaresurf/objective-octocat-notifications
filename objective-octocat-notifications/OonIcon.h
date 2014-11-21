// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// OonIcon.h
// objective-octocat-notifications
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OonIconType) {
    OonIconStatusBarDefault,
    OonIconStatusBarActive,
    OonIconStatusBarHasNotifications
};

@interface OonIcon : NSImage

+ (OonIcon *)forStatusBarFrom:(OonIconType) type;

@end