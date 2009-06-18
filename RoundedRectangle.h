// Note: This rounded rectangle class isn't part of my code. It was 
// taken from: http://www.cocoadev.com/index.pl?RoundedRectangles
// Accessed: 25th January, 2007

#import <Cocoa/Cocoa.h>


@interface NSBezierPath(RoundedRectangle)

/**
Returns a closed bezier path describing a rectangle with curved corners
	The corner radius will be trimmed to not exceed half of the lesser rectangle dimension.
 */
+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect) aRect cornerRadius: (double) radius;

@end
