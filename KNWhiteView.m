//
//  KNWhiteView.m
//  Clarus
//
//  Created by Daniel Kennett on 20/01/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import "KNWhiteView.h"


@implementation KNWhiteView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)mouseDownCanMoveWindow {
	return NO;
}

-(BOOL)showsRightBorder {
	return showsRightBorder;
}

-(void)setShowsRightBorder:(BOOL)shows {
	showsRightBorder = shows;
	[self setNeedsDisplay:YES];
}

-(BOOL)showsLeftBorder {
	return showsLeftBorder;
}

-(BOOL)isFlipped {
	return flipped;
}

-(void)setIsFlipped:(BOOL)f {
	flipped = f;
}

-(void)setShowsLeftBorder:(BOOL)shows {
	showsLeftBorder = shows;
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    
    [[NSColor colorWithCalibratedWhite:0.98 alpha:1.0] set];
    NSRectFill(rect);
	
	if (showsRightBorder) {
		[[NSColor lightGrayColor] set];
		[NSBezierPath strokeLineFromPoint:NSMakePoint([self bounds].size.width, 0.0) toPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height)];
		
	}
	
	if (showsLeftBorder) {
		[[NSColor lightGrayColor] set];
		[NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, 0.0) toPoint:NSMakePoint(0.0, [self bounds].size.height)];
		
	}
}

@end
