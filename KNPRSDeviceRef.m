//
//  KNPRSDeviceRef.m
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNPRSDeviceRef.h"


@implementation KNPRSDeviceRef

-(id)init {
	return [self initWithBasePath:nil];
}

-(id)initWithBasePath:(NSString *)aPath {
	
	if (self = [super init]) {
		[self setBasePath:aPath];
	}
	return self;
}


@synthesize basePath;

-(NSString *)name {
	return [[self basePath] lastPathComponent];
}

-(NSImage *)icon {
	return [[NSWorkspace sharedWorkspace] iconForFile:[self basePath]];
}

@end
