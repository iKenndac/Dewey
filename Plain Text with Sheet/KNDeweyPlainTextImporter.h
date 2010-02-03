//
//  KNDeweyTextAndRTFImporter.h
//  Dewey
//
//  Created by Daniel Kennett on 16/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDeweyBookFormatImporter.h"

@interface KNDeweyPlainTextImporter : NSObject <KNDeweyBookFormatImporter> {
	__weak id <KNDeweyBookFormatImporterDelegate> delegate;
	
	NSURL *incomingFileURL;
	NSWindow *parentWindow; 
	KNPRSDevice *device;
	
	NSString *bookTitle;
	NSString *bookAuthor;

	IBOutlet NSWindow *bookDetailsSheet;
	
}

@property (nonatomic, copy, readwrite) NSURL *incomingFileURL;
@property (nonatomic, retain, readwrite) NSWindow *parentWindow;
@property (nonatomic, retain, readwrite) KNPRSDevice *device;

@property (nonatomic, copy, readwrite) NSString *bookTitle;
@property (nonatomic, copy, readwrite) NSString *bookAuthor;

-(IBAction)cancelImport:(id)sender;
-(IBAction)acceptImport:(id)sender;

@end
