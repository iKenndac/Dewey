//
//  KNDeweyBookImporter.h
//  Dewey
//
//  Created by Daniel Kennett on 14/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDeweyBookFormatImporter.h"

@interface KNDeweyBookImporter : NSObject <KNDeweyBookFormatImporterDelegate> {
	
	NSArray *knownImporters;
	NSMutableArray *workingImporters;
	
}

+(KNDeweyBookImporter *)sharedImporter;
-(NSArray *)supportedFileExtensions;

-(void)importFromFileAtURL:(NSURL *)fileURL inWindow:(NSWindow *)aWindow toDevice:(KNPRSDevice *)aDevice;

@end
