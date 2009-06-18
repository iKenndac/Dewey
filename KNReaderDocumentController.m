//
//  KNPRSDocumentController.m
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNReaderDocumentController.h"
#import "KNPRSDevice.h"
#import "DeviceSelectionController.h"
#import "KNReaderDocument.h"

@implementation KNReaderDocumentController

-(id)openUntitledDocumentAndDisplay:(BOOL)displayDocument error:(NSError **)outError {
		
	KNPRSDevice *device = [DeviceSelectionController askForDevice];
	
	if (device) {

		KNReaderDocument *doc = [[KNReaderDocument alloc] initWithDevice:device];
		
		
		[self addDocument:doc];
		
		[doc makeWindowControllers];
		[doc showWindows];

		return doc;
		
	} else {
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"KNDocumentCreationFailure",
                                  NSLocalizedDescriptionKey,
                                  @"The document could not be opened.", NSLocalizedFailureReasonErrorKey, nil];
        
        *outError = [[NSError errorWithDomain:@"KNDocumentCreationFailure"
                                         code:1
                                     userInfo:userInfo] retain];
		return nil;
		
	} 
	
	
	
}

-(NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
    return [NSString stringWithFormat:@"Dewey: %@", displayName];
}

-(BOOL)presentError:(NSError *)error {
	
	if ([[error domain] caseInsensitiveCompare:@"KNDocumentCreationFailure"] == NSOrderedSame) {
		return NO;
	} else {
		return [super presentError:error];
	}
} 

@end
