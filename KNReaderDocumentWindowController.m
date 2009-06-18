//
//  KNReaderDocumentWindowController.m
//  PRS Reader
//
//  Created by Daniel Kennett on 07/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import "KNReaderDocumentWindowController.h"
#import "KNReaderDocument.h"
#import "KNTableCorner.h"
#import "KNTableHeader.h"
#import "KNDividerCell.h"

@interface KNReaderDocumentWindowController (Private)

-(void)removePlaylistSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
-(void)setUndoActionTitleIfAllowed:(NSString *)title;

@end

@implementation KNReaderDocumentWindowController

-(void)awakeFromNib {
 
	[bookInformationNoSelectionView setFrame:[bookInformationView bounds]];
	[bookInformationView addSubview:bookInformationNoSelectionView];
	
    [[self window] setMovableByWindowBackground:YES];
    sortAscending = YES;
    
    for (NSTableColumn *column in [bookList tableColumns]) {
        
        [column setHeaderCell:[[[KNTableHeader alloc] initWithTitle:[[column headerCell] stringValue]
                                                          alignment:NSLeftTextAlignment
                                                     drawSeparators:YES
                                                       canBeClicked:YES] autorelease]];
        
    }
    
    [bookList setVerticalMotionCanBeginDrag:NO];
    [bookList setCornerView:[[[KNTableCorner alloc] initWithShowsRightEdge:NO] autorelease]];
	   
    [bookProviderList registerForDraggedTypes:[NSArray arrayWithObject:@"KNPRSBookIDPBoardType"]];
    [bookList registerForDraggedTypes:[NSArray arrayWithObject:@"KNPRSBookIDPBoardType"]];
    
    [bookProviderList selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    [[self document] addObserver:self
             forKeyPath:@"device.playlists"
                options:0
                context:nil];
    
    [self addObserver:self
           forKeyPath:@"document"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:nil]; 
    
    [self setSelectedProvider:[[self document] device]];


}

@synthesize selectedProvider;

#pragma mark -
#pragma mark KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"device.playlists"]) {
        [bookProviderList reloadData];
    } else if ([keyPath isEqualToString:@"document"]) {
        
        id oldDoc = [change valueForKey:NSKeyValueChangeOldKey];
        
        if (oldDoc && !(oldDoc == [NSNull null])) {
            [oldDoc removeObserver:self forKeyPath:@"device.playlists"];
        }
        
        id newDoc = [change valueForKey:NSKeyValueChangeNewKey];
        
        if (newDoc && !(newDoc == [NSNull null])) {
            [newDoc addObserver:self
                     forKeyPath:@"device.playlists"
                        options:0
                        context:nil];
        }
        
        [bookProviderList reloadData];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -
#pragma mark KVO Properties for UI

+(NSSet *)keyPathsForValuesAffectingRemovePlaylistButtonEnabled {
    return [NSSet setWithObjects:@"selectedProvider", nil];
}

-(BOOL)removePlaylistButtonEnabled {
    return [[self selectedProvider] isKindOfClass:[KNPRSPlaylist class]];
}

#pragma mark -
#pragma mark Actions

-(IBAction)addPlaylist:(id)sender {
	
	[self addNewPlaylist:[[[KNPRSPlaylist alloc] init] autorelease]];
	
}

-(IBAction)removePlaylist:(id)sender {
 
	if ([bookProviderList selectedRow] == 0) {
		NSBeep();
		return;
	}
	
    KNPRSPlaylist *playlist = [[[[self document] device] playlists] objectAtIndex:[bookProviderList selectedRow] - 2];
    
    if ([[playlist books] count] > 0) {
        NSBeginAlertSheet([NSString stringWithFormat:@"Are you sure you want to remove “%@”?", [playlist title]],
                          @"Remove",
                          @"Cancel",
                          nil, 
                          [self window], 
                          self, 
                          @selector(removePlaylistSheetDidEnd:returnCode:contextInfo:), 
                          nil, 
                          playlist, 
                          [NSString stringWithFormat:@"This collection contains %d books.", [[playlist books] count]]);
    } else {
        [self removePlaylistSheetDidEnd:nil returnCode:NSAlertDefaultReturn contextInfo:playlist];
    }
}

-(void)removePlaylistSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertDefaultReturn) {
        
        [(id)contextInfo retain];
        
        NSArray *playlists = [[[[self document] device] playlists] copy];
        
        if ([playlists count] == 1) {
            [self setSelectedProvider:[[self document] device]];
        } else if (contextInfo == [playlists lastObject]) {
            [self setSelectedProvider:[playlists objectAtIndex:[playlists indexOfObject:contextInfo] - 1]]; 
        } else {
            [self setSelectedProvider:[playlists objectAtIndex:[playlists indexOfObject:contextInfo] + 1]];
        }
        
        [self removeExistingPlaylist:contextInfo];

        [[NSNotificationCenter defaultCenter] postNotificationName:NSTableViewSelectionDidChangeNotification object:bookProviderList];
               
        [playlists release];
        [(id)contextInfo release];
        
    }
}

-(IBAction)removeBooks:(id)sender {
	
	if ([bookProviderList selectedRow] == 0) {
		NSBeep();
		return;
	}
	
	KNPRSPlaylist *playlist = [[[[self document] device] playlists] objectAtIndex:[bookProviderList selectedRow] - 2];
	
	NSMutableArray *booksThatMadeIt = [NSMutableArray array];
	
	for (KNPRSBook *book in [playlist books]) {
		if (![[bookController selectedObjects] containsObject:book]) {
			[booksThatMadeIt addObject:book];
		}
	}
	
	[self setPlaylistContents:playlist 
					  toBooks:[NSArray arrayWithArray:booksThatMadeIt] 
					operation:kOperationRemoveBooks];
}


#pragma mark -
#pragma mark TableViews

// Unfortunately, since we're doing something a bit special in the 
// source list (listing the playlists, plus a divider and an "all books"
// item), we can't just use bindings. Boo! :-(

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (aTableView == bookProviderList) {
        return [[[[self document] device] playlists] count] + 2; 
    } else {
        return 0;
    }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
    if (aTableView == bookProviderList) {
        
        if ([[aTableColumn identifier] isEqualToString:@"icon"]) {
            if (rowIndex == 0) {
                return [[[self document] device] icon];
            } else if (rowIndex == 1) {
                return nil;
            } else {
                return [[[[[self document] device] playlists] objectAtIndex:rowIndex - 2] icon];
            }
            
        } else {
            
            if (rowIndex == 0) {
                return [[[self document] device] title];
            } else if (rowIndex == 1) {
                return @"-";
            } else {
                return [[[[[self document] device] playlists] objectAtIndex:rowIndex - 2] title];
            }
        }
    } else {
        return nil;
    }
        
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if (row == 1 && tableView == bookProviderList) {
		return [[[KNDividerCell alloc] init] autorelease];;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	if (row == 1 && tableView == bookProviderList) {
		return 7.0;
	} else {
		return [tableView rowHeight];
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    if (aTableView == bookProviderList) {
        return (rowIndex != 1);
    } else {
        return YES;
    }
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    if ([notification object] == bookProviderList) {
        if ([bookProviderList selectedRow] == 0) {
            [self setSelectedProvider:[[self document] device]];
        } else {
            [self setSelectedProvider:[[[[self document] device] playlists] objectAtIndex:[bookProviderList selectedRow] - 2]];
        }
    }
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return (rowIndex > 1);
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    if (rowIndex > 1) {
		
		KNPRSPlaylist *playlist = [[[[self document] device] playlists] objectAtIndex:rowIndex - 2];
		
		[self renamePlaylist:playlist withTitle:anObject];
    }
    
}

#pragma mark -
#pragma mark Drag and Drop

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
	
    if  (aTableView == bookList) {
        
        NSArray *books = [[bookController arrangedObjects] objectsAtIndexes:rowIndexes];
        
        NSMutableArray *bookIds = [[NSMutableArray alloc] initWithCapacity:[books count]];
        
        for (KNPRSBook *book in books) {
            [bookIds addObject:[NSString stringWithFormat:@"%d", [book bookId]]];
        }
        
        [pboard declareTypes:[NSArray arrayWithObject:@"KNPRSBookIDPBoardType"] owner:[self selectedProvider]];
        [pboard setPropertyList:[NSDictionary dictionaryWithObject:bookIds forKey:@"bookIds"] forType:@"KNPRSBookIDPBoardType"];
        
        return YES;
    } 
    
    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
 
    if (aTableView == bookProviderList && row > 1) {
     
        if ([[[info draggingPasteboard] types] containsObject:@"KNPRSBookIDPBoardType"]) {
            
            if (operation == NSTableViewDropAbove) {
                if (row == [self numberOfRowsInTableView:aTableView]) {
                    return NSDragOperationCopy;
                }
                [aTableView setDropRow:row dropOperation:NSTableViewDropOn];
            }
            return NSDragOperationCopy;
        }
    }
    
    if (aTableView == bookList) {
     
        if ([self selectedProvider] == [[self document] device]) {
            return NSDragOperationNone; // No reordering the book!
        }
        
        [aTableView setDropRow:row dropOperation:NSTableViewDropAbove];
        
        return NSDragOperationMove;
        
    }
       
    return NSDragOperationNone;

}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {    
    
    if ([[[info draggingPasteboard] types] containsObject:@"KNPRSBookIDPBoardType"]) {
        
        NSString *type = [[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:@"KNPRSBookIDPBoardType"]];
        
        id plist = [[info draggingPasteboard] propertyListForType:type];
        
        NSArray *bookIds = [plist valueForKey:@"bookIds"];
        NSMutableArray *books = [[NSMutableArray alloc] initWithCapacity:[bookIds count]];
        
        for (NSString *idString in bookIds) {
            
            KNPRSBook *book = [[[self document] device] bookWithId:[idString integerValue]];
            
            if (book) {
                [books addObject:book];
            }
        }
        
        
        if (aTableView == bookProviderList && row > 1) {
            NSUInteger correctedRow = row - 2;
            
            KNPRSPlaylist *playlist = nil; 
            
            NSArray *playlists = [[[self document] device] playlists];
            
            if (correctedRow >= [playlists count]) {
                // Make a new playlist
				
				[[[self document] undoManager] beginUndoGrouping];
                
				KNPRSPlaylist *playlist = [[[KNPRSPlaylist alloc] init] autorelease];
				
				[self addNewPlaylist:playlist];
				[self setPlaylistContents:playlist
								  toBooks:books 
								operation:kOperationAddBooks];
				
				[[[self document] undoManager] endUndoGrouping];
				
				[self setUndoActionTitleIfAllowed:@"Add Collection"];
                
								
                [bookProviderList selectRowIndexes:[NSIndexSet indexSetWithIndex:[[[[self document] device] playlists] indexOfObject:playlist] + 2] byExtendingSelection:NO];
                
            } else {
        
                playlist = [playlists objectAtIndex:correctedRow];
                [books removeObjectsInArray:[playlist books]];
				// So we don't get duplicates
				[self setPlaylistContents:playlist
								  toBooks:[[playlist books] arrayByAddingObjectsFromArray:books]
								operation:kOperationAddBooks];
				
            }
            return YES;
        }
        
        if (aTableView == bookList) {
            
            // Get the first book above the dropped row that isn't in the books list, then 
            // add the book list after it.
            
            KNPRSPlaylist *playlist = [self selectedProvider];
            NSMutableArray *unaffectedBooks = [[[[self selectedProvider] books] mutableCopy] autorelease];
            
            KNPRSBook *targetBook = nil;
            
            if (row == 0) {
                // Easy! Sling 'em at the beginning
				
                [unaffectedBooks removeObjectsInArray:books];
				
				[self setPlaylistContents:playlist 
								  toBooks:[books arrayByAddingObjectsFromArray:unaffectedBooks]
								operation:kOperationRearrangeBooks];
				 
                return YES;
				 
				 
                
            } else if (row == [[playlist books] count]) {
                
                // Also easy - put them at the end
				
                [unaffectedBooks removeObjectsInArray:books];
                
				[self setPlaylistContents:playlist 
								  toBooks:[unaffectedBooks arrayByAddingObjectsFromArray:books]
								operation:kOperationRearrangeBooks];
			
                return YES;
            } else {
                
                // Harder
             
                targetBook = [[[self selectedProvider] books] objectAtIndex:row];
                
                while ([books containsObject:targetBook]) {
                    row--;
                    targetBook = [[[self selectedProvider] books] objectAtIndex:row];
                    
                }
                
                [unaffectedBooks removeObjectsInArray:books];
                
                NSMutableArray *rearrangedBooks = [NSMutableArray arrayWithCapacity:[[[self selectedProvider] books] count]];
                
                for (KNPRSBook *book in unaffectedBooks) {
                    if (book == targetBook) {
                        [rearrangedBooks addObjectsFromArray:books];
                    }
                    
                    [rearrangedBooks addObject:book];
                }
                
				[self setPlaylistContents:playlist
								  toBooks:rearrangedBooks
								operation:kOperationRearrangeBooks];

                return YES;
            }
            
        }
        
    }
    
    return NO;

}

#pragma mark -
#pragma mark Keys

- (void)keyDown:(NSEvent*)event {
	
	BOOL deleteKeyEvent = NO;
	
	if ([event type] == NSKeyDown) {
		
		NSString* pressedChars = [event characters];
		
		if ([pressedChars length] == 1) {
			
			unichar pressedUnichar = [pressedChars characterAtIndex:0];
			
			if ((pressedUnichar == NSDeleteCharacter) || (pressedUnichar == 0xf728)) {
				deleteKeyEvent = YES;
			}
		}
	}
	
	// If it was a delete key, handle the event specially, otherwise call super.
	if (deleteKeyEvent) {
		// This will end up calling deleteBackward: or deleteForward:.
		[self interpretKeyEvents:[NSArray arrayWithObject:event]];
		
	} else {
		[super keyDown:event];
	}
}

- (void)deleteBackward:(id)sender {
	
	if ([[self window] firstResponder] == bookProviderList) {
		[self removePlaylist:sender];
	} else {
		[self removeBooks:sender];
	}
	
	
}

- (void)deleteForward:(id)sender {
	[self deleteBackward:sender];
}

#pragma mark -
#pragma mark Undo and Redo

-(void)setPlaylistContents:(KNPRSPlaylist *)playlist toBooks:(NSArray *)books operation:(KNPlaylistOperation)operation {
	
	KNPlaylistOperation oppositeOperation = kOperationRearrangeBooks;
	
	if (operation == kOperationAddBooks) {
		oppositeOperation = kOperationRemoveBooks;
	} else if (operation == kOperationRemoveBooks) {
		oppositeOperation == kOperationAddBooks;
	}
	
	[[[[self document] undoManager] prepareWithInvocationTarget:self] setPlaylistContents:playlist
																				  toBooks:[playlist books] 
																				operation:oppositeOperation];
	
	switch (operation) {
		case kOperationAddBooks:
			[self setUndoActionTitleIfAllowed:[books count] - [[playlist books] count] == 1 ? @"Add Book" : @"Add Books"];
			break;
		case kOperationRemoveBooks:
			[self setUndoActionTitleIfAllowed:[[playlist books] count] - [books count] == 1 ? @"Remove Book" : @"Remove Books"];
			break;
		case kOperationRearrangeBooks:
			[self setUndoActionTitleIfAllowed:@"Rearrange Books"];
			break;
		default:
			break;
	}
	 
	[playlist setBooks:books];
}


-(void)renamePlaylist:(KNPRSPlaylist *)playlist withTitle:(NSString *)title {
	
	[[[[self document] undoManager] prepareWithInvocationTarget:self] renamePlaylist:playlist withTitle:[playlist title]];
	[self setUndoActionTitleIfAllowed:@"Rename Collection"];
	
	[playlist setTitle:title];
	
	[bookProviderList reloadData];
}



-(void)addNewPlaylist:(KNPRSPlaylist *)playlist {
	
	[[[[self document] undoManager] prepareWithInvocationTarget:self] removeExistingPlaylist:playlist];
	[self setUndoActionTitleIfAllowed:@"Add Collection"];
	
	[[[self document] device] addPlaylist:playlist];
	
}

-(void)removeExistingPlaylist:(KNPRSPlaylist *)playlist {
	
	[[[[self document] undoManager] prepareWithInvocationTarget:self] addNewPlaylist:playlist];
	[self setUndoActionTitleIfAllowed:@"Remove Collection"];
	
	[[[self document] device] removePlaylist:playlist];
	
}

-(void)setUndoActionTitleIfAllowed:(NSString *)title {

	NSUndoManager *undoManager = [[self document] undoManager];
	
	if ([undoManager isUndoing]) {
		[undoManager setActionName:[undoManager undoActionName]];
	} else if ([undoManager isRedoing]) {
		[undoManager setActionName:[undoManager redoActionName]];
	} else {
		[undoManager setActionName:title];
	}
	
	
}

#pragma mark -
#pragma mark SplitView

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
    
    return NSMakeRect([[[splitView subviews] objectAtIndex:0] frame].size.width - 28.0, 
                      [[[splitView subviews] objectAtIndex:0] frame].size.height - 28.0, 
                      28.0, 
                      28.0);
    
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
    return [sender bounds].size.width / 2;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset {
    return 150.0;
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    
    float dividerThickness = [sender dividerThickness];
    NSRect newFrame = [sender frame];
    NSRect leftFrame = [[[sender subviews] objectAtIndex:0] frame]; 
    NSRect rightFrame = [[[sender subviews] objectAtIndex:1] frame];
		
    leftFrame.size.width = leftFrame.size.width; 
    leftFrame.size.height = newFrame.size.height;
    leftFrame.origin = NSMakePoint(0,0);
    rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
    rightFrame.size.height = newFrame.size.height;
    rightFrame.origin.x = leftFrame.size.width + dividerThickness;
    
    // handle the case of de-zoomed window clipping the splitview thumb
    if (rightFrame.size.width < [sender frame].size.width / 2) {
        leftFrame.size.width = [sender frame].size.width / 2 - dividerThickness;
        rightFrame.size.width = ([sender frame].size.width / 2) - leftFrame.size.width - dividerThickness;
    }

    [[[sender subviews] objectAtIndex:0] setFrame:leftFrame];
    [[[sender subviews] objectAtIndex:1] setFrame:rightFrame];
   
    
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification {

    /*
    
	if ([[NSApp currentEvent] type] == NSLeftMouseDragged) {
		
		[[[self document] resourceManager] setProperty:[NSNumber numberWithFloat:[[[[self view] subviews] objectAtIndex:0] frame].size.width]
                                                forKey:[NSString stringWithFormat:@"SplitPosition_%@", [self nibName]]];
	}

     */
     
}

-(void)dealloc {
    [[self document] removeObserver:self forKeyPath:@"document"];
    
    [super dealloc];
}

@end
