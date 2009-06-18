//
//  KNDevice.h
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol KNDevice <NSObject>

-(NSImage *)icon;
-(NSString *)name;

@end

@protocol KNDeviceProvider <NSObject>

-(NSArray *)devices;

-(void)addObserver:(NSObject *)anObserver forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
-(void)removeObserver:(NSObject *)anObserver forKeyPath:(NSString *)keyPath;

@end