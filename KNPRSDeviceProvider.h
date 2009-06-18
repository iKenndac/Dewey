//
//  KNPRSDeviceProvider.h
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDevice.h"

@interface KNPRSDeviceProvider : NSObject <KNDeviceProvider> {
	NSArray *devices;
	BOOL isUpdating;
	BOOL updateIsQueued;
}

@property (nonatomic, readwrite, retain) NSArray *devices;
@property (nonatomic, readwrite) BOOL updateIsQueued;
@property (nonatomic, readwrite) BOOL isUpdating;

@end
