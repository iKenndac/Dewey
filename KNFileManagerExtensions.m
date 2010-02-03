//
//  KNFileManagerExtensions.m
//  Dewey
//
//  Created by Daniel Kennett on 14/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNFileManagerExtensions.h"


@implementation NSFileManager (KNFileManagerExtensions)

-(NSString *)pathWithUniqueNameForFile:(NSString *)fileName inDirectory:(NSString *)directoryPath {
	
	// This method passes back a unique file name for the passed file and path. 
	// So, for example, if the caller wants to put a file called "Hello.txt" in ~/Desktop
	// and that file already exists, it'll give back ~/Desktop/Hello 2.txt".
	// The method respects extensions and will keep incrementing the number until it finds a unique name. 
	
	BOOL fileMade = NO;
	NSFileManager *manager = [NSFileManager defaultManager];
	int uNum = 2;
	
	if (![manager fileExistsAtPath:[directoryPath stringByAppendingPathComponent:fileName]]) {
		return [directoryPath stringByAppendingPathComponent:fileName];
	} else {
		
		while (!fileMade) {
			
			NSString *newName = [NSString stringWithFormat:@"%@ %d.%@", [fileName stringByDeletingPathExtension], uNum, [fileName pathExtension]];
			
			NSString *totalPath = [directoryPath stringByAppendingPathComponent:newName];
			
			if ([manager fileExistsAtPath:totalPath]) { 
				uNum++;
			} else {
				return totalPath;
			}
		}
	}
	
	return [directoryPath stringByAppendingPathComponent:fileName];
	
}

@end
