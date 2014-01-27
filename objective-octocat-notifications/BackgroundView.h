// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// BackgroundView.h
// objective-octocat-notifications
//

#define ARROW_WIDTH 12
#define ARROW_HEIGHT 8

@interface BackgroundView : NSView
{
    NSInteger _arrowX;
}

@property (nonatomic, assign) NSInteger arrowX;

@end
