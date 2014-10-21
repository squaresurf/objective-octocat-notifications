// Copyright (c) 2014 Daniel Paul Searles
//
// See the file LICENSE in the root of this project for copying permission.
//
// StatusItemView.m
// objective-octocat-notifications
//

#import "StatusItemView.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize hasNotifications = _hasNotifications;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];

    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
        _hasNotifications = NO;
    }
    return self;
}


#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef myContext = [[NSGraphicsContext // 1
                               currentContext] graphicsPort];

	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];

    [NSGraphicsContext saveGraphicsState];
    
    if (self.isHighlighted) {
        CGContextSetRGBFillColor (myContext, 0.9, 0.9, 0.9, 1);
    } else if (self.hasNotifications) {
        CGFloat red = 0.25490196078431;
        CGFloat green = 0.51372549019608;
        CGFloat blue = 0.76862745098039;

        CGContextSetRGBFillColor (myContext, red, green, blue, 1);

        NSShadow* theShadow = [[NSShadow alloc] init];
        [theShadow setShadowOffset:NSMakeSize(0, 0)];
        [theShadow setShadowBlurRadius:8.0];

        // Use a partially transparent color for shapes that overlap.
        [theShadow setShadowColor:[NSColor colorWithSRGBRed:red green:green blue:blue alpha:0.8]];

        [theShadow set];
    } else {
        CGContextSetRGBFillColor (myContext, 0.1, 0.1, 0.1, 1);
    }

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:CGRectMake(8, 8, 8, 8)];
    [path fill];

    [NSGraphicsContext restoreGraphicsState];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) {
        return;
    }

    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

- (void)setHasNotifications:(BOOL)hasNotifications
{
    if (_hasNotifications == hasNotifications) {
        return;
    }

    _hasNotifications = hasNotifications;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
