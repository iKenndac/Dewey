//
//  KNWhiteView.h
//  Clarus
//
//  Created by Daniel Kennett on 20/01/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KNWhiteView : NSView {
	BOOL showsRightBorder;
	BOOL showsLeftBorder;
	BOOL flipped;
}

-(BOOL)showsRightBorder;
-(void)setShowsRightBorder:(BOOL)shows;

-(void)setIsFlipped:(BOOL)f;

-(BOOL)showsLeftBorder;
-(void)setShowsLeftBorder:(BOOL)shows;

@end
