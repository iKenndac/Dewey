//
//  KNiPodSelectionView.m
//  Music Rescue 4
//
//  Created by Daniel Kennett on 15/02/2008.
//  Copyright 2008 KennettNet Software Limited. All rights reserved.
//

#import "KNDeviceSelectionView.h"
#import "RoundedRectangle.h"
#import "TintedImage.h"

@interface KNDeviceSelectionView (Private)

-(NSDictionary *)textAttributes;
-(NSDictionary *)fullSizeTextAttributes;

@end

@implementation KNDeviceSelectionView

@synthesize noDevicesHeader;
@synthesize noDevicesExplanation;
@synthesize deviceProvider;
@synthesize selectedDevice;
@synthesize delegate;

#define widthPerItem 100
#define heightPerItem 100

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setNoDevicesHeader:@"No Devices Found"];
		[self setNoDevicesExplanation:@"Make sure your device is plugged in and recognised by this computer."];
		rowsNeeded = 1;
		[[self window] setAcceptsMouseMovedEvents:YES];
		
		[self addObserver:self 
			   forKeyPath:@"selectedDevice"
				  options:0
				  context:nil];
		
		[self addObserver:self 
			   forKeyPath:@"deviceProvider"
				  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
				  context:nil];
		
    }
    return self;
}

-(void)dealloc {
	
	[self setDeviceProvider:nil];
	[self setSelectedDevice:nil];
	[self setNoDevicesHeader:nil];
	[self setNoDevicesExplanation:nil];
	[self setDelegate:nil];
	
	[self removeObserver:self forKeyPath:@"selectedDevice"];
	[self removeObserver:self forKeyPath:@"deviceProvider"];
	
	[super dealloc];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedDevice"]) {
		[self setNeedsDisplay:YES];
	} else if ([keyPath isEqualToString:@"deviceProvider"]) {
		
		id <KNDeviceProvider> oldProvider = [change valueForKey:NSKeyValueChangeOldKey];
		
		if ((NSNull *)oldProvider != [NSNull null]) {
			[oldProvider removeObserver:self forKeyPath:@"devices"];
		}
		
		id <KNDeviceProvider> newProvider = [change valueForKey:NSKeyValueChangeNewKey];
		
		if ((NSNull *)newProvider != [NSNull null]) {
			[newProvider addObserver:self 
						  forKeyPath:@"devices"
							 options:0
						 context:nil];
		}
		
		[self updateDisplay];
		
	} else if ([keyPath isEqualToString:@"devices"]) {
		
		if (![[[self deviceProvider] devices] containsObject:[self selectedDevice]]) {
			if ([[[self deviceProvider] devices] count] == 0) {
				[self setSelectedDevice:nil];
			} else {
				[self setSelectedDevice:[[[self deviceProvider] devices] objectAtIndex:0]];
			}
		}
		
		[self updateDisplay];
		[self setNeedsDisplay:YES];
		
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


-(void)awakeFromNib {
	
	
}

-(BOOL)acceptsFirstResponder {
	return YES;
	
}



-(void)setSelectionIndex:(int)index {

	if (index < [[[self deviceProvider] devices] count] && index > -1) {
		[self setSelectedDevice:[[[self deviceProvider] devices] objectAtIndex:index]];
	}
	
}


-(void)updateDisplay {
	
	int colsPerRow = floor([self bounds].size.width / widthPerItem);
	rowsNeeded = ceil((float)[[[self deviceProvider] devices] count] / (float)colsPerRow);
	
	if (rowsNeeded == 0) {
		rowsNeeded = 1;
	}
	
	//NSLog(@"cols: %d, rows: %d", colsPerRow, rowsNeeded);
	
	//if ([[self superview] isKindOfClass:[NSScrollView class]]) {
		//[self setFrameSize:NSMakeSize([iPods count] * 100, [self frame].size.height)];
	//}
	
	if ([delegate respondsToSelector:@selector(iPodSelectionView:needsHeight:)]) {
		[delegate performSelector:@selector(iPodSelectionView:needsHeight:) 
					   withObject:self 
					   withObject:[NSNumber numberWithInt:rowsNeeded * heightPerItem]];
	}
	
	[self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Mouse

- (void)mouseDown:(NSEvent *)theEvent {

	NSPoint event_location = [theEvent locationInWindow];
	NSPoint localPoint = [self convertPoint:event_location fromView:nil];

	//NSLog(@"%d", index);
	
	int colsPerRow = floor([self bounds].size.width / widthPerItem);
	int mouseRow = ceil((float)localPoint.y / (float)heightPerItem);
	
	int index = ((mouseRow - 1) * colsPerRow) + floor(localPoint.x / widthPerItem);
	
	
	
	if (index < [[[self deviceProvider] devices] count]) {
		[self setSelectedDevice:[[[self deviceProvider] devices] objectAtIndex:index]];
		mouseDownIndex = index;
		mousePoint = localPoint;
		
	}
	
	[self setNeedsDisplay:YES];
	
}

- (void)mouseUp:(NSEvent *)theEvent {
	
	mouseDownIndex = -1;
	mousePoint = NSZeroPoint;
	[self setNeedsDisplay:YES];
	
}

- (void)mouseDragged:(NSEvent *)theEvent {
	
	NSPoint event_location = [theEvent locationInWindow];
	NSPoint localPoint = [self convertPoint:event_location fromView:nil];

	mousePoint = localPoint;
	[self setNeedsDisplay:YES];

}

-(BOOL)isFlipped {
	return YES;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect {
	
	// To do: 
	// - Make it draw
	
	//float currentXOffset = 0;
	
	unsigned int textRectHeight = 15;
	unsigned int textHPadding = 10;
	unsigned int textVPadding = 5;
	
	int colsPerRow = floor([self bounds].size.width / widthPerItem);
	int currentRef = 0;
	int currentCol = 1;
	int currentRow = 1;
	
	NSSize imageSize = NSMakeSize(64.0, 64.0);
	
	id <KNDevice> device;
	
	if ([[[self deviceProvider] devices] count] > 0) {
		
		for (currentRow = 1; currentRow <= rowsNeeded; currentRow++) {
			
			for (currentCol = 1; currentCol <= colsPerRow; currentCol++) {
				
				if (currentRef < [[[self deviceProvider] devices] count]) {
					
					// Layout looks like this:
					// 
					//    +-----------------+
					//    |                 |
					//    |    +-------+    |
					//    |    | iPod  |    |
					//    |    | Image |    |
					//    |    |       |    |
					//    |    +-------+    |
					//    |                 |
					//    |    iPod Name    |
					//    |                 |
					//    +-----------------+
					
					device = [[[self deviceProvider] devices] objectAtIndex:currentRef];
					
					NSRect itemBox = NSMakeRect((currentCol - 1) * widthPerItem , (currentRow - 1) * heightPerItem, widthPerItem, heightPerItem);
					//currentXOffset += widthPerItem;
					
					// Selection drawing
					
					if (device == [self selectedDevice]) {
						
						[[[NSColor lightGrayColor] colorWithAlphaComponent:0.2] set];
						[[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(itemBox, 1.0, 1.0) cornerRadius:10.0] fill];
						
						[[NSColor lightGrayColor] set];
						
						NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(itemBox, 2.0, 2.0) cornerRadius:10.0];
						[path setLineWidth:2.0];
						[path stroke];
						
					}		
					
					itemBox = NSOffsetRect(itemBox, 0.5, 0.5); // For drawing smoothness
					
					// Image drawing
					
					NSRect imageRect = NSMakeRect((itemBox.size.width / 2) - (imageSize.width /2), 10, imageSize.width, imageSize.height);
					imageRect = NSOffsetRect(imageRect, itemBox.origin.x, itemBox.origin.y);
					
					NSImage *im = [device icon];
					BOOL flipped = [im isFlipped];
					[im setFlipped:[self isFlipped]];
					[im setScalesWhenResized:YES];
					[im setSize:imageRect.size];
					
					if (currentRef == mouseDownIndex && NSPointInRect(mousePoint, imageRect)) {
						// Selected
						im = [im tintedImageWithColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
					} 
					
					
					[im drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
					
					[im setFlipped:flipped];
					
					// Text drawing 
					
					NSRect textRect = NSMakeRect(textHPadding, NSMaxY(imageRect) + textVPadding, 
												 widthPerItem - (textHPadding * 2), textRectHeight);
					textRect = NSOffsetRect(textRect, itemBox.origin.x, 0);
					
					[[device name] drawInRect:textRect withAttributes:[self textAttributes]];
					
					
					currentRef++;
					
				}
			}	
		}
		
	} else {
		
		// No iPods!
		
		NSRect textRect = NSMakeRect(0.5, 5, [self bounds].size.width, 20);
		
		[[self noDevicesHeader] drawInRect:textRect withAttributes:[self fullSizeTextAttributes]];
		
		textRect = NSMakeRect(20, 30, [self bounds].size.width - 40, 70);
		
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		[style setAlignment:NSCenterTextAlignment];		
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0], NSFontAttributeName, 
				[NSColor blackColor], NSForegroundColorAttributeName,
				[style autorelease], NSParagraphStyleAttributeName , nil];

		
		[[self noDevicesExplanation] drawInRect:textRect withAttributes:dict];
		
		
	}
}

-(NSDictionary *)textAttributes {
	
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setAlignment:NSCenterTextAlignment];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	 
	
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0], NSFontAttributeName, 
			[NSColor blackColor], NSForegroundColorAttributeName,
			[style autorelease], NSParagraphStyleAttributeName , nil];
	
	
}

-(NSDictionary *)fullSizeTextAttributes {
	
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setAlignment:NSCenterTextAlignment];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	
	
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSFont boldSystemFontOfSize:13.0], NSFontAttributeName, 
			[NSColor blackColor], NSForegroundColorAttributeName,
			[style autorelease], NSParagraphStyleAttributeName , nil];
	
	
}


@end
