//
//  KNPRSLayout.h
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KNPRSLayout : NSObject {

    NSInteger part;
    NSInteger scale;
    NSData *data;
    
}

-(id)initWithXMLElement:(NSXMLElement *)element; 

@property NSInteger part;
@property NSInteger scale;
@property (nonatomic, retain, readwrite) NSData *data;

-(NSXMLElement *)xmlElement;

@end
