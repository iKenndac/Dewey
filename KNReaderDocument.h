//
//  MyDocument.h
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright KennettNet Software Limited 2009 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "KNPRSDevice.h"

@interface KNReaderDocument : NSDocument
{
    
    KNPRSDevice *device;
    
}
@property (retain) KNPRSDevice *device;

-(id)initWithDevice:(KNPRSDevice *)dev;

@end
