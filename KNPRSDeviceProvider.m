//
//  KNPRSDeviceProvider.m
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNPRSDeviceProvider.h"
#import "KNPRSDeviceRef.h"
#import "KNPRSDevice.h"

@interface KNPRSDeviceProvider (Private)

-(void)updateDevices:(NSNotification *)notification;

@end

@implementation KNPRSDeviceProvider

-(id)init {
	
	if (self = [super init]) {
		[self updateDevices:nil];
		
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(updateDevices:)
																   name:NSWorkspaceDidMountNotification
																 object:[NSWorkspace sharedWorkspace]];
		
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(updateDevices:)
																   name:NSWorkspaceDidUnmountNotification
																 object:[NSWorkspace sharedWorkspace]];
		
	}
	return self;
}

@synthesize devices;
@synthesize isUpdating;
@synthesize updateIsQueued;

-(void)updateDevices:(NSNotification *)notification {
	
	if (isUpdating) {
		[self setUpdateIsQueued:YES];
	} else {
		
		[self setIsUpdating:YES];
		
		[NSThread detachNewThreadSelector:@selector(performThreadedDeviceUpdate)
								 toTarget:self 
							   withObject:nil];
		
	}
}

-(void)updateComplete {
	
	[self setIsUpdating:NO];

	if ([self updateIsQueued]) {
		
		[self updateDevices:nil];
	}
}

-(void)performThreadedDeviceUpdate {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray *newDevices = [NSMutableArray array];
	
	NSArray *volumes = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
	// Use local media so I can use my hard drive to test
	
	for (NSString *path in volumes) {
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[KNPRSDevice databasePathFromVolumePath:path]]) {
			
			BOOL alreadyKnowAboutThisVolume = NO;
			
			// If we already have a KNPRSDeviceRef for this volume, use the existing instance.
			// This allows the KNDeviceSelectionView to retain its selection when the devices change.
			
			for (KNPRSDeviceRef *ref in [self devices]) {
				if ([[ref basePath] isEqualToString:path]) {
					alreadyKnowAboutThisVolume = YES;
					[newDevices addObject:ref];
				}
			}
			
			if (!alreadyKnowAboutThisVolume) {
				
				[newDevices addObject:[[[KNPRSDeviceRef alloc] initWithBasePath:path] autorelease]];
			}
			
			[self performSelectorOnMainThread:@selector(setDevices:) 
								   withObject:[NSArray arrayWithArray:newDevices]
								waitUntilDone:YES];
			
		}
	}
	
	
	
	[self performSelectorOnMainThread:@selector(updateComplete)
						   withObject:nil
						waitUntilDone:YES];
	
	[pool release];
	
}



-(void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
	[super addObserver:observer forKeyPath:keyPath options:options context:context];
}

-(void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
	[super removeObserver:observer forKeyPath:keyPath];
}

-(void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWorkspaceDidMountNotification
												  object:[NSWorkspace sharedWorkspace]];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSWorkspaceDidUnmountNotification
												  object:[NSWorkspace sharedWorkspace]];
	
	[self setDevices:nil];
	[super dealloc];
}

@end
