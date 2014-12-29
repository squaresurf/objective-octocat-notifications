// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// GithubAvatar.h
// objective-octocat-notifications
//

#import <Cocoa/Cocoa.h>

/**
 * A class that represents a Github avatar.
 */
@interface GithubAvatar : NSImage

/**
 * A method to get a background image to draw on.
 *
 * @return A GithubAvatar background to draw on.
 */
+ (GithubAvatar *)backgroundImageForSize:(NSSize)size;

/**
 * Get a GithubAvatar from a NSURL.
 *
 * @param url The url to load and draw on top of our background.
 *
 * @return A GithubAvatar to set for the notification content image.
 */
+ (GithubAvatar *)avatarFromURL:(NSURL *)url;

@end
