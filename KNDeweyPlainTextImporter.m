//
//  KNDeweyTextAndRTFImporter.m
//  Dewey
//
//  Created by Daniel Kennett on 16/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNDeweyPlainTextImporter.h"
#import <AddressBook/AddressBook.h>
#import "KNFileManagerExtensions.h"

@implementation KNDeweyPlainTextImporter

+(NSSet *)formatFileExtensions {
	return [NSSet setWithObjects:@"txt", nil];
}

+(NSString *)formatName {
	return @"Plain Text";
}

+(NSString *)formatMimeType {
	return @"text/plain";
}

@synthesize delegate;

-(void)dealloc {
	[self setDelegate:nil];
	[super dealloc];
}

-(void)importFromFileAtURL:(NSURL *)fileURL 
				  inWindow:(NSWindow *)aWindow 
				  toDevice:(KNPRSDevice *)aDevice {
	
	
	KNPRSBook *book = [[KNPRSBook alloc] init];
	
	[book setTitle:[[[fileURL path] lastPathComponent] stringByDeletingPathExtension]];
	[book setAuthor:nil];
	[book setCurrentPage:1];
	[book setDate:[[[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:nil] 
				   valueForKey:NSFileCreationDate]];
	
	[book setFileSize:[[[[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:nil]
						valueForKey:NSFileSize] unsignedIntegerValue]]; 
	[book setMimeType:[[self class] formatMimeType]];
	
	
	// Copy the file!!
	
	NSString *destinationPath = [[NSFileManager defaultManager] pathWithUniqueNameForFile:[[fileURL path] lastPathComponent] 
																			  inDirectory:[aDevice bookContainerPath]];
	
	NSError *error;
	
	if (![[NSFileManager defaultManager] copyItemAtPath:[fileURL path]
												 toPath:destinationPath
												  error:&error]) {
		
		[[self delegate] importer:self importOfFileAtURL:fileURL failedWithError:error];
		
	} else {
		
		// Success!
		
		[book setRelativePath:[destinationPath stringByReplacingOccurrencesOfString:[aDevice volumePath]
																		 withString:@""]];
		
		// Strip leading /
		if ([[[book relativePath] substringToIndex:1] isEqualToString:@"/"]) {
			[book setRelativePath:[[book relativePath] substringFromIndex:1]];
		}
		
		[aDevice addBook:book];
		
		[[self delegate] importer:self importOfFileAtURL:fileURL succeededWithBook:book];
		
	}
	
	[book release];
	book = nil;
	
	
}

@end
