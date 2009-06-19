//
//  MyDocument.m
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright KennettNet Software Limited 2009 . All rights reserved.
//

#import "KNReaderDocument.h"
#import "KNReaderDocumentWindowController.h"

@implementation KNReaderDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
    
    }
    return self;
}
	

-(void)makeWindowControllers {
    
    KNReaderDocumentWindowController *controller = [[KNReaderDocumentWindowController alloc] initWithWindowNibName:@"PRSDocument"];

    [self addWindowController:controller];

}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    [aController setDocument:self];
}

- (id)initWithType:(NSString *)typeName error:(NSError **)outError {
	
	if (self = [self init]) {
		[self setDevice:[[[KNPRSDevice alloc] init] autorelease]];
	}
	return self;
}


-(BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem {
	
	if ([anItem action] == @selector(saveDocument:)) {
		return [self isDocumentEdited];
	} else {
		return [super validateUserInterfaceItem:anItem];
	}
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    return [[device xmlDocument] XMLDataWithOptions:NSXMLNodePrettyPrint | NSXMLNodeCompactEmptyElement];
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    
	NSString *basePath = [KNPRSDevice volumePathFromDatabasePath:[[self fileURL] path]];
	
    [self setDevice:[[[KNPRSDevice alloc] initWithPathToReaderVolume:basePath] autorelease]];
    
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}


@synthesize device;
@end
