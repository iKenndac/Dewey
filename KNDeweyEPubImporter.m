//
//  KNDeweyEPubImporter.m
//  Dewey
//
//  Created by Daniel Kennett on 16/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNDeweyEPubImporter.h"
#import "KNFileManagerExtensions.h"

@interface KNDeweyEPubImporter (Private)

-(NSString *)createUUID;
-(void)failWithInvalidFile;
-(NSString *)pathWithOpfInternalPath:(NSString *)internalPath relativeTo:(NSString *)rootPath;
-(NSString *)opfPathOfManifestItemWithId:(NSString *)itemId inManifest:(NSXMLElement *)manifest;
-(NSData *)coverThumbnailWithImagePath:(NSString *)imagePath;

@end

@implementation KNDeweyEPubImporter

+(NSSet *)formatFileExtensions {
	return [NSSet setWithObjects:@"epub", nil];
}

+(NSString *)formatName {
	return @"ePub";
}

+(NSString *)formatMimeType {
	return @"application/epub+zip";
}

@synthesize delegate;
@synthesize incomingFileURL;
@synthesize parentWindow;
@synthesize device;

-(void)dealloc {
	
	if (unzipTask) {
		[unzipTask terminate];
		[unzipTask release];
		unzipTask = nil;
	}
	
	[self setIncomingFileURL:nil];
	[self setParentWindow:nil];
	[self setDevice:nil];
	
	
	[self setDelegate:nil];
	[super dealloc];
}

-(void)importFromFileAtURL:(NSURL *)fileURL 
				  inWindow:(NSWindow *)aWindow 
				  toDevice:(KNPRSDevice *)aDevice {
	
	[self setParentWindow:aWindow];
	[self setDevice:aDevice];
	[self setIncomingFileURL:fileURL];
	
	// First, create a temporary directory to expand our files into
	
	NSString *tempDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self createUUID]];
	
	BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:tempDirPath
															  attributes:nil];
	
	if (success) {
		
		unzipTask = [[NSTask alloc] init];
		[unzipTask setCurrentDirectoryPath:tempDirPath];
		[unzipTask setArguments:[NSArray arrayWithObjects:@"-qq", [fileURL path], nil]];
		[unzipTask setLaunchPath:@"/usr/bin/unzip"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(taskDidEnd:)
													 name:NSTaskDidTerminateNotification
												   object:unzipTask];
		
		[unzipTask launch];
		
	}
	
}	

-(void)taskDidEnd:(NSNotification *)aNotification {
	
	[self retain];
	[self autorelease];
	// Retain self since the delegates are sent before final cleanup is done, and it 
	// causes problems if we get deallocated before the end of the task. 
	
	int status = [unzipTask terminationStatus];
	if (!(status == 0 || status == 1 || status == 2)) {
		// ^ Success || warnings || possibly non-fatal errors. 
		[self failWithInvalidFile];
		return;
	}
	
	NSString *unzipPath = [unzipTask currentDirectoryPath];
	
	NSString *containerXmlPath = [[unzipPath stringByAppendingPathComponent:@"META-INF"]
								  stringByAppendingPathComponent:@"container.xml"];
	
	NSXMLDocument *containerXmlDocument = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:containerXmlPath]
																			   options:0
																				 error:nil];
	[containerXmlDocument autorelease];
	
	if (!containerXmlDocument) {
		[self failWithInvalidFile];
		return;
	}
	
	// container.rootfiles.rootfile -> attrib:fullpath
	
	NSXMLElement *rootFileElement = [[[[[containerXmlDocument rootElement] 
										elementsForName:@"rootfiles"] lastObject] 
									  elementsForName:@"rootfile"] lastObject];
	
	NSString *internalOpfPath = [[rootFileElement attributeForName:@"full-path"] stringValue];
	
	if (!internalOpfPath) {
		[self failWithInvalidFile];
		return;
	} 
	
	NSString *opfFilePath = [self pathWithOpfInternalPath:internalOpfPath
											   relativeTo:unzipPath];
	
	NSXMLDocument *opfDocument = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:opfFilePath]
																	  options:0
																		error:nil];
	[opfDocument autorelease];
	
	if (!opfDocument) {
		[self failWithInvalidFile];
		return;
	} 
	
	KNPRSBook *book = [[KNPRSBook alloc] init];
	
	[book setTitle:[[[[[[opfDocument rootElement] elementsForName:@"metadata"] lastObject]
					  elementsForName:@"dc:title"] lastObject] stringValue]];
	[book setAuthor:[[[[[[opfDocument rootElement] elementsForName:@"metadata"] lastObject]
					   elementsForName:@"dc:creator"] lastObject] stringValue]];
	
	// Cover
	
	NSArray *metaElements = [[[[opfDocument rootElement] elementsForName:@"metadata"] lastObject]
							 elementsForName:@"meta"];
	
	NSString *manifestCoverId = nil;
	
	for (NSXMLElement *meta in metaElements) {
		if ([[[meta attributeForName:@"name"] stringValue] isEqualToString:@"cover"]) {
			manifestCoverId = [[meta attributeForName:@"content"] stringValue];
			break;
		}
	}
	
	if (manifestCoverId) {
		NSString *opfCoverPath = [self opfPathOfManifestItemWithId:manifestCoverId 
														inManifest:[[[opfDocument rootElement] elementsForName:@"manifest"] lastObject]];
		
		NSString *coverPath = [self pathWithOpfInternalPath:opfCoverPath 
												 relativeTo:unzipPath];
		[book setThumbnailImageData:[self coverThumbnailWithImagePath:coverPath]];
	}
	
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
		
		[[self delegate] importer:self 
				importOfFileAtURL:[self incomingFileURL]
				  failedWithError:error];
		
	} else {
		
		// Success!
		
		[book setRelativePath:[destinationPath stringByReplacingOccurrencesOfString:[[self device] volumePath]
																		 withString:@""]];
		
		// Strip leading /
		if ([[[book relativePath] substringToIndex:1] isEqualToString:@"/"]) {
			[book setRelativePath:[[book relativePath] substringFromIndex:1]];
		}
		
		[[self device] addBook:book];
		
		[[self delegate] importer:self 
				importOfFileAtURL:[self incomingFileURL]
				succeededWithBook:book];
		
	}
	
	[book release];
	book = nil;
	
}

-(void)failWithInvalidFile {
	
	[[NSFileManager defaultManager] removeItemAtPath:[unzipTask currentDirectoryPath]
											   error:nil];
	
	[[self delegate] importer:self
			importOfFileAtURL:[self incomingFileURL]
			  failedWithError:[NSError errorWithDomain:kImporterInvalidInputFileError
												  code:[unzipTask terminationStatus]
											  userInfo:nil]];
	
	[self release];
}

-(NSString *)pathWithOpfInternalPath:(NSString *)internalPath relativeTo:(NSString *)rootPath {
	
	NSArray *opfPathComponents = [internalPath componentsSeparatedByString:@"/"];
	NSString *finalPath = [[rootPath copy] autorelease];
	
	for (NSString *pathComponent in opfPathComponents) {
		finalPath = [finalPath stringByAppendingPathComponent:pathComponent];
	}	
	
	return finalPath;
}

-(NSString *)opfPathOfManifestItemWithId:(NSString *)itemId inManifest:(NSXMLElement *)manifest {
	
	for (NSXMLElement *manifestElement in [manifest elementsForName:@"item"]) {
		
		if ([[[manifestElement attributeForName:@"id"] stringValue] isEqualToString:itemId]) {
			return [[manifestElement attributeForName:@"href"] stringValue];
		}
	}
	return nil;
}

-(NSData *)coverThumbnailWithImagePath:(NSString *)imagePath {
	
	if ((!imagePath) || (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])) {
		return nil;
	}
	
	CIImage *sourceImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:imagePath]];
	
	if (sourceImage) {
		
		float scale = 1.0;
		float width = [sourceImage extent].size.width;
		float height = [sourceImage extent].size.height;
		
		if (width > 0.0 && height > 0.0) {
			
			if (width > height) {
				// Scale by width 
				scale = kThumbnailMaximumSize/width;
			} else {
				scale = kThumbnailMaximumSize/height;
			}
			
			CIImage *thumb = [sourceImage imageByApplyingTransform:CGAffineTransformMakeScale(scale, scale)];
			
			NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCIImage:thumb];
			
			NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] 
																   forKey:NSImageCompressionFactor];
			NSData *thumbnailData = [rep representationUsingType:NSJPEGFileType
													  properties:imageProps];
			
			
			[rep release];
			
			return thumbnailData;
		}
	}
	
	return nil;
	
	
}

#pragma mark -

-(NSString *)createUUID {
	//create a new UUID
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);
	//get the string representation of the UUID
	NSString	*newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [newUUID autorelease];
}

@end
