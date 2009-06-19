//
//  NewDocumentController.m
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "DeviceSelectionController.h"
#import "KNPRSDeviceProvider.h"
#import "KNPRSDeviceRef.h"
#import "KNReaderDocumentController.h"

@implementation DeviceSelectionController

+(NSString *)askForDevicePath {
	
	DeviceSelectionController *controller = [[DeviceSelectionController alloc] initWithWindowNibName:@"DeviceSelectionController"];
    
    NSString *devicePath = [controller askForDevicePath];
	
	[controller release];
    
    return devicePath;
	
}

-(void)awakeFromNib {
	
	[deviceSelectionView setDelegate:self];
	[deviceSelectionView setDeviceProvider:[[[KNPRSDeviceProvider alloc] init] autorelease]];
	[deviceSelectionView setSelectionIndex:0];
	
	
}



-(NSString *)askForDevicePath {
    
	//[loadingProgress startAnimation:nil];
	//[loadingProgress setUsesThreadedAnimation:YES];	
	
	[NSApp runModalForWindow:[self window]];
	return selectedDevicePath;
}



-(IBAction)doStandardOpen:(id)sender {
	
	NSURL *proposedDatabaseURL = [NSURL fileURLWithPath:[KNPRSDevice databasePathFromVolumePath:[(KNPRSDeviceRef *)[deviceSelectionView selectedDevice] basePath]]];
	
	if ([[KNReaderDocumentController sharedDocumentController] documentForURL:proposedDatabaseURL]) {
		
		NSRunAlertPanel(@"This device is already open in Dewey", 
						@"To continue, please close any Dewey windows using this device.", 
						@"OK", 
						nil, 
						nil);		
		
	} else {
		
		// Init the device
		selectedDevicePath = [[(KNPRSDeviceRef *)[deviceSelectionView selectedDevice] basePath] copy];
		
		if (!selectedDevicePath) {
		
			NSRunAlertPanel(@"Could not open device", 
							@"An error occurred while trying to read the device's database.", 
							@"OK", 
							nil, 
							nil);	
			
		}
		
		[NSApp stopModalWithCode:0];
		
	}
}




-(IBAction)bailOut:(id)sender {
    
    //[startupWindow close];
	[[self window] setIsVisible:NO];
	
    //createdDevice = nil;
    
    [NSApp stopModalWithCode:0];
	
    
}

- (void)windowWillClose:(NSNotification *)notification {
	[self bailOut:nil];
}


-(void)iPodSelectionView:(KNDeviceSelectionView *)view needsHeight:(NSNumber *)height {
	
		// 209 + height
		
		float newHeight = 195 + [height intValue];
		
		//NSLog(@"Existing: %1.2f, New: %1.2f", [startupWindow frame].size.height, newHeight);
		
		if ([[self window] frame].size.height != newHeight) {
			NSRect oldFrame = [[self window] frame];
			
			float yPoint = oldFrame.origin.y + oldFrame.size.height;
			
			NSRect newFrame = NSMakeRect(oldFrame.origin.x, yPoint - newHeight,
										 oldFrame.size.width, newHeight);
			
			[[self window] setFrame:newFrame display:YES animate:YES];
			
		}
		
	
}

-(void)dealloc {

	[selectedDevicePath release];
	selectedDevicePath = nil;
	
	[deviceSelectionView setDelegate:nil];
	
	[super dealloc];
}

@end
