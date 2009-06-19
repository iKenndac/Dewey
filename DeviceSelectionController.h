//
//  NewDocumentController.h
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDeviceSelectionView.h"
#import "KNPRSDevice.h"

@interface DeviceSelectionController : NSWindowController {

	IBOutlet KNDeviceSelectionView *deviceSelectionView;
	NSString *selectedDevicePath;
}

+(NSString *)askForDevicePath;
-(NSString *)askForDevicePath;

-(IBAction)doStandardOpen:(id)sender;	
-(IBAction)bailOut:(id)sender;

@end
