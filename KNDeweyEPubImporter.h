//
//  KNDeweyEPubImporter.h
//  Dewey
//
//  Created by Daniel Kennett on 16/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDeweyBookFormatImporter.h"


@interface KNDeweyEPubImporter : NSObject <KNDeweyBookFormatImporter> {
	__weak id <KNDeweyBookFormatImporterDelegate> delegate;

	NSTask *unzipTask;
	
	NSURL *incomingFileURL;
	NSWindow *parentWindow; 
	KNPRSDevice *device;
	
}

@property (nonatomic, copy, readwrite) NSURL *incomingFileURL;
@property (nonatomic, retain, readwrite) NSWindow *parentWindow;
@property (nonatomic, retain, readwrite) KNPRSDevice *device;


@end
