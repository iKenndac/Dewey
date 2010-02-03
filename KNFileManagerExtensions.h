//
//  KNFileManagerExtensions.h
//  Dewey
//
//  Created by Daniel Kennett on 14/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (KNFileManagerExtensions)

-(NSString *)pathWithUniqueNameForFile:(NSString *)fileName inDirectory:(NSString *)directoryPath;

@end
