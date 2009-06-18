//
//  KNReaderDocumentWindowController.h
//  PRS Reader
//
//  Created by Daniel Kennett on 07/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNPRSPlaylist.h"

typedef enum {
	
	kOperationAddBooks,
	kOperationRemoveBooks,
	kOperationRearrangeBooks
	
} KNPlaylistOperation;

@interface KNReaderDocumentWindowController : NSWindowController {
    BOOL sortAscending; 
    
    IBOutlet NSTableView *bookList;
    IBOutlet NSTableView *bookProviderList;
    IBOutlet NSArrayController *bookController;
	
	IBOutlet NSView *bookInformationView;
	IBOutlet NSView *bookInformationNoSelectionView;
	
    id <KNPRSBookProvider> selectedProvider;
}

@property (assign, nonatomic, readwrite) id <KNPRSBookProvider> selectedProvider;

-(IBAction)addPlaylist:(id)sender;
-(IBAction)removePlaylist:(id)sender;
-(IBAction)removeBooks:(id)sender;

#pragma mark -
#pragma mark Undo

-(void)setPlaylistContents:(KNPRSPlaylist *)playlist toBooks:(NSArray *)books operation:(KNPlaylistOperation)operation;
-(void)renamePlaylist:(KNPRSPlaylist *)playlist withTitle:(NSString *)title;
-(void)addNewPlaylist:(KNPRSPlaylist *)playlist;
-(void)removeExistingPlaylist:(KNPRSPlaylist *)playlist;
				

@end
