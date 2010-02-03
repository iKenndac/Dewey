//
//  KNDeweyBookImporter.m
//  Dewey
//
//  Created by Daniel Kennett on 14/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNDeweyBookImporter.h"
#import "KNDeweyPDFImporter.h"
#import "KNDeweyPlainTextImporter.h"
#import "KNDeweyRTFImporter.h"
#import "KNDeweyEPubImporter.h"

@implementation KNDeweyBookImporter


static KNDeweyBookImporter *staticImporter;

+(KNDeweyBookImporter *)sharedImporter {
	
	if (!staticImporter) {
		[[KNDeweyBookImporter alloc] init];
	}
	return staticImporter;
}

-(id)init {
	
	if (!staticImporter) {
		
		if (self = [super init]) {
			
			// Find implementors of KNDeweyBookFormatImporter  and add them to our list;
			
			NSMutableArray *importers = [NSMutableArray array];
			
			Class pdfClass = [KNDeweyPDFImporter class];
			[importers addObject:pdfClass];
			
			Class plainTextClass = [KNDeweyPlainTextImporter class];
			[importers addObject:plainTextClass];
			
			Class rtfClass = [KNDeweyRTFImporter class];
			[importers addObject:rtfClass];
			
			Class epubClass = [KNDeweyEPubImporter class];
			[importers addObject:epubClass];
			
			knownImporters = [[NSArray alloc] initWithArray:importers];
			workingImporters = [[NSMutableArray alloc] init];
		}
		staticImporter = self;
	} else {
		[self release];
	}
	
	return staticImporter;
}


-(void)dealloc {
	[knownImporters release];
	[workingImporters release];
	
	[super dealloc];
}


#pragma mark -

-(NSArray *)supportedFileExtensions {

	NSArray *extensions = [NSArray array];
	
	for (Class importer in knownImporters) {
		extensions = [extensions arrayByAddingObjectsFromArray:[[importer formatFileExtensions] allObjects]];
	}
	
	return extensions;
}

-(void)importFromFileAtURL:(NSURL *)fileURL inWindow:(NSWindow *)aWindow toDevice:(KNPRSDevice *)aDevice {
	
	for (Class importerClass in knownImporters) {

		if ([[importerClass formatFileExtensions] containsObject:[[fileURL path] pathExtension]]) {
			
			id <KNDeweyBookFormatImporter> importer = [[importerClass alloc] init];
			
			[workingImporters addObject:importer];
			
			[importer setDelegate:self];
			
			[importer importFromFileAtURL:fileURL 
								 inWindow:aWindow
								 toDevice:aDevice];
			
			[importer release];
			
			break;
		}
	}
}

#pragma mark -

-(void)importer:(id <KNDeweyBookFormatImporter>)anImporter importOfFileAtURL:(NSURL *)fileURL failedWithError:(NSError *)error {
	[workingImporters removeObject:anImporter];
	
	
	[NSApp presentError:error];
}

-(void)importer:(id <KNDeweyBookFormatImporter>)anImporter importOfFileAtURL:(NSURL *)fileURL succeededWithBook:(KNPRSBook *)aBook {
	[workingImporters removeObject:anImporter];
}


@end
