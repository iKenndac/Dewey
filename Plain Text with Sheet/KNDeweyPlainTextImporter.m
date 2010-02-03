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

-(id)init {
	if (self = [super init]) {
		[self setBookTitle:@"Unknown"];
		
		ABPerson *me = [[ABAddressBook sharedAddressBook] me];
		
		NSString *firstName = [me valueForProperty:kABFirstNameProperty];
		NSString *lastName = [me valueForProperty:kABLastNameProperty];
		
		NSString *name = nil;
		
		if (firstName && lastName) {
			name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
		} else if (firstName) {
			name = firstName;
		} else if (lastName) {
			name = lastName;
		} 
		
		[self setBookAuthor:name];
		
		[NSBundle loadNibNamed:@"KNDeweyPlainTextImporter" owner:self]; 
		
	}
	return self;
}

@synthesize delegate;
@synthesize incomingFileURL;
@synthesize parentWindow;
@synthesize device;
@synthesize bookTitle;
@synthesize bookAuthor;

-(void)dealloc {
	[self setDelegate:nil];
	[self setIncomingFileURL:nil];
	[self setParentWindow:nil];
	[self setDevice:nil];
	[self setBookTitle:nil];
	[self setBookAuthor:nil];
	[super dealloc];
}

-(void)importFromFileAtURL:(NSURL *)fileURL 
				  inWindow:(NSWindow *)aWindow 
				  toDevice:(KNPRSDevice *)aDevice {
	
	[self setParentWindow:aWindow];
	[self setIncomingFileURL:fileURL];
	[self setDevice:aDevice];
	[self setBookTitle:[[[fileURL path] lastPathComponent] stringByDeletingPathExtension]];
	
	[self performSelector:@selector(beginImport) 
			   withObject:nil
			   afterDelay:0.0];
	
}
	
#pragma mark -

-(void)beginImport {
	
	[NSApp beginSheet:bookDetailsSheet
	   modalForWindow:[self parentWindow]
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
}

-(IBAction)cancelImport:(id)sender {
	[NSApp endSheet:bookDetailsSheet];
	[bookDetailsSheet orderOut:self];
	
	[[self delegate] importer:self
			importOfFileAtURL:[self incomingFileURL]
			  failedWithError:[NSError errorWithDomain:kImporterUserCancelledError
												  code:1
											  userInfo:nil]];
}

-(IBAction)acceptImport:(id)sender {
	
	KNPRSBook *book = [[KNPRSBook alloc] init];
	
	[book setTitle:[self bookTitle]];
	[book setAuthor:[self bookAuthor]];
	[book setCurrentPage:1];
	[book setDate:[[[NSFileManager defaultManager] fileAttributesAtPath:[[self incomingFileURL] path]
														   traverseLink:YES] 
				   valueForKey:NSFileCreationDate]];
	
	[book setFileSize:[[[[NSFileManager defaultManager] fileAttributesAtPath:[[self incomingFileURL] path]
																traverseLink:YES]
						valueForKey:NSFileSize] unsignedIntegerValue]]; 
	[book setMimeType:[[self class] formatMimeType]];
	 
	
	// Copy the file!!
	
	NSString *destinationPath = [[NSFileManager defaultManager] pathWithUniqueNameForFile:[[[self incomingFileURL] path] lastPathComponent] 
																			  inDirectory:[[self device] bookContainerPath]];
	
	NSError *error;
	
	if (![[NSFileManager defaultManager] copyItemAtPath:[[self incomingFileURL] path]
												 toPath:destinationPath
												  error:&error]) {
		
		[[self delegate] importer:self importOfFileAtURL:[self incomingFileURL] failedWithError:error];
		
	} else {
		
		// Success!
		
		[book setRelativePath:[destinationPath stringByReplacingOccurrencesOfString:[[self device] volumePath]
																		 withString:@""]];
		
		// Strip leading /
		if ([[[book relativePath] substringToIndex:1] isEqualToString:@"/"]) {
			[book setRelativePath:[[book relativePath] substringFromIndex:1]];
		}
		
		[[self device] addBook:book];
		
		[[self delegate] importer:self importOfFileAtURL:[self incomingFileURL] succeededWithBook:book];
		
	}
	
	[book release];
	book = nil;
	
	[NSApp endSheet:bookDetailsSheet];
	[bookDetailsSheet orderOut:nil];
	
	
}

@end
