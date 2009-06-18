//
//  AppDelegate.m
//  Dewey
//
//  Created by Daniel Kennett on 17/06/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "AppDelegate.h"
#import "KNReaderDocumentController.h"

@implementation AppDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
	[KNReaderDocumentController sharedDocumentController];
}

@end
