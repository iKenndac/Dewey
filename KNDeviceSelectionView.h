//
//  KNiPodSelectionView.h
//  Music Rescue 4
//
//  Created by Daniel Kennett on 15/02/2008.
//  Copyright 2008 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDevice.h"

@interface KNDeviceSelectionView : NSView {

	id <KNDevice> selectedDevice;
	id <KNDeviceProvider> deviceProvider;
	id delegate;
	int rowsNeeded;
	
	int mouseDownIndex;
	NSPoint mousePoint;
	
	NSString *noDevicesHeader;
	NSString *noDevicesExplanation;
}

@property (nonatomic, readwrite, copy) NSString *noDevicesHeader;
@property (nonatomic, readwrite, copy) NSString *noDevicesExplanation;

-(void)setSelectionIndex:(int)index;
-(void)updateDisplay;

@property (readwrite, nonatomic, assign) id delegate;
@property (readwrite, nonatomic, retain) id <KNDevice> selectedDevice;
@property (readwrite, nonatomic, retain) id <KNDeviceProvider> deviceProvider;

@end
