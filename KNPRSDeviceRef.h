//
//  KNPRSDeviceRef.h
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDevice.h"

@interface KNPRSDeviceRef : NSObject <KNDevice> {
	NSString *basePath;
}

-(id)initWithBasePath:(NSString *)aPath;

@property (nonatomic, retain, readwrite) NSString *basePath;

@end
