//
//  KNDeweyPDFImporter.m
//  Dewey
//
//  Created by Daniel Kennett on 14/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNDeweyPDFImporter.h"
#import <Quartz/Quartz.h>
#import "KNFileManagerExtensions.h"

@interface KNDeweyPDFImporter (Private)

-(NSData *)jpgThumbnailForPDFPage:(PDFPage *)page;

@end

@implementation KNDeweyPDFImporter

+(NSSet *)formatFileExtensions {
	return [NSSet setWithObject:@"pdf"];
}

+(NSString *)formatName {
	return @"PDF";
}

+(NSString *)formatMimeType {
	return @"application/pdf";
}

@synthesize delegate;

-(void)dealloc {
	[self setDelegate:nil];
	[super dealloc];
}

-(void)importFromFileAtURL:(NSURL *)fileURL inWindow:(NSWindow *)aWindow toDevice:(KNPRSDevice *)aDevice {
	
	// This is a simple importer, which needs no UI or threading. Hooray!
	
	PDFDocument *document = [[PDFDocument alloc] initWithURL:fileURL];
	
	if (document) {
		
		KNPRSBook *book = [[KNPRSBook alloc] init];
		
		[book setTitle:[[document documentAttributes] valueForKey:PDFDocumentTitleAttribute]];
		[book setAuthor:[[document documentAttributes] valueForKey:PDFDocumentAuthorAttribute]];
		[book setCurrentPage:1];
		[book setDate:[[[NSFileManager defaultManager] fileAttributesAtPath:[fileURL path]
															   traverseLink:YES] 
					   valueForKey:NSFileCreationDate]];
		
		KNPRSBookmark *firstPageHistory = [[[KNPRSBookmark alloc] init] autorelease];
		[firstPageHistory setDate:[NSDate date]];
		[firstPageHistory setPage:1];
		[firstPageHistory setTotalPages:[document pageCount]];
		
		[book setHistory:[NSArray arrayWithObject:firstPageHistory]];
		[book setFileSize:[[[[NSFileManager defaultManager] fileAttributesAtPath:[fileURL path]
																	traverseLink:YES]
							valueForKey:NSFileSize] unsignedIntegerValue]]; 
		[book setMimeType:[[self class] formatMimeType]];
		
		
		// Cover thumbnail
		
		PDFPage *firstPage = [document pageAtIndex:0];
		
		if (firstPage) {
			[book setThumbnailImageData:[self jpgThumbnailForPDFPage:firstPage]];			
		}
		
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
		
	} else {
	
		[[self delegate] importer:self 
				importOfFileAtURL:fileURL
						   failedWithError:[NSError errorWithDomain:kImporterInvalidInputFileError
															   code:1
														   userInfo:nil]];
		
	}
	
	[document release];
	document = nil;
}

-(NSData *)jpgThumbnailForPDFPage:(PDFPage *)page {
	
	NSRect pageRect = [page boundsForBox:kPDFDisplayBoxCropBox];
	NSImage *image = [[NSImage alloc] initWithSize:pageRect.size];
	
	[image lockFocus];
	
	[[NSColor whiteColor] set];
	NSRectFill(pageRect);
	
	[page drawWithBox:kPDFDisplayBoxCropBox];
	
	[image unlockFocus];
	
	// Create the thumbnail, maximum size 80x80px
	
	NSSize thumbnailSize; 
	
	if (pageRect.size.width > pageRect.size.height) {
		thumbnailSize.width = kThumbnailMaximumSize;
		thumbnailSize.height = kThumbnailMaximumSize * (pageRect.size.height / pageRect.size.width); 
	} else {
		thumbnailSize.height = kThumbnailMaximumSize;
		thumbnailSize.width = kThumbnailMaximumSize * (pageRect.size.width / pageRect.size.height);
	}
		
	NSImage *thumbnail = [[NSImage alloc] initWithSize:thumbnailSize];
	
	[thumbnail lockFocus];
	[image drawInRect:NSMakeRect(0.0, 0.0, thumbnailSize.width, thumbnailSize.height) 
			 fromRect:NSZeroRect
			operation:NSCompositeCopy
			 fraction:1.0];
	[thumbnail unlockFocus];
	
	[image release];
	image = nil;
	
	// Covert to bitmap
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[thumbnail TIFFRepresentation]];
	
	[thumbnail release];
	thumbnail = nil;
	
	NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] 
														   forKey:NSImageCompressionFactor];

	
	return [rep representationUsingType:NSJPEGFileType properties:imageProps];

}



@end
