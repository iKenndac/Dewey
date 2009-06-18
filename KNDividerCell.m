//
//  KNDividerCell.m
//  PRS Reader
//
//  Created by Daniel Kennett on 10/05/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNDividerCell.h"


@implementation KNDividerCell

- (id)copyWithZone:(NSZone *)zone {
	
	return [[KNDividerCell alloc] init];
	
}



-(void)drawWithFrame:(NSRect)frame inView:(NSView *)view {
	
	
	NSPoint dividerStart = NSMakePoint(NSMinX(frame) + 32.5, frame.origin.y + (frame.size.height / 2) + 0.5);
	NSPoint dividerEnd = NSMakePoint(NSMaxX(frame) - 31.5, frame.origin.y + (frame.size.height / 2) + 0.5);
	
	[[NSColor whiteColor] set];
	
	[NSBezierPath strokeLineFromPoint:dividerStart toPoint:dividerEnd];
	
	dividerStart = NSMakePoint(NSMinX(frame) + 32, frame.origin.y + (frame.size.height / 2));
	dividerEnd = NSMakePoint(NSMaxX(frame) - 32, frame.origin.y + (frame.size.height / 2));
	
	[[NSColor grayColor] set];
	
	[NSBezierPath strokeLineFromPoint:dividerStart toPoint:dividerEnd];
	
	return;
	
}
	
@end
