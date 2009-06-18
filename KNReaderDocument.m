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

-(id)initWithDevice:(KNPRSDevice *)dev {
	
	if (self = [self init]) {
		
		[self setDevice:dev];
		[self setFileURL:[NSURL fileURLWithPath:[KNPRSDevice databasePathFromVolumePath:[dev volumePath]]]];
		
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
		device = [[KNPRSDevice alloc] init];
	}
	return self;
}
	

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    return [[device xmlDocument] XMLDataWithOptions:NSXMLNodePrettyPrint | NSXMLNodeCompactEmptyElement | NSXMLNodePrettyPrint];
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data
                                                     options:0
                                                       error:nil];
    
    if (doc) {
        device = [[KNPRSDevice alloc] initWithXMLDocument:[doc autorelease]];
    }
    
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
