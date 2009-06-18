//
//  KNFrameView.m
//  Music Rescue 4
//
//  Created by Daniel Kennett on 25/02/2008.
//  Copyright 2008 KennettNet Software Limited. All rights reserved.
//

#import "KNFrameView.h"


@implementation KNFrameView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	
	
	[[[NSColor whiteColor] colorWithAlphaComponent:0.6] set];
	
	[NSBezierPath fillRect:[self bounds]];
	
	
	[[NSColor lightGrayColor] set];
	
	NSRect border = NSMakeRect(0.5, 0.5, [self bounds].size.width - 1, [self bounds].size.height - 1);
	
	[NSBezierPath strokeRect:border];
	

	
}

@end
