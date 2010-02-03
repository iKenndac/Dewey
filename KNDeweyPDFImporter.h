//
//  KNDeweyPDFImporter.h
//  Dewey
//
//  Created by Daniel Kennett on 14/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNDeweyBookFormatImporter.h"


@interface KNDeweyPDFImporter : NSObject <KNDeweyBookFormatImporter> {
	__weak id <KNDeweyBookFormatImporterDelegate> delegate;
}

@end
