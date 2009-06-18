//
//  KNPRSLayout.m
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import "KNPRSLayout.h"
#import "NSData+Base64.h"

@implementation KNPRSLayout

@synthesize part;
@synthesize scale;
@synthesize data;

-(id)initWithXMLElement:(NSXMLElement *)element {
    
    if (self = [super init]) {
        
        [self setPart:[[[element attributeForName:@"part"] stringValue] integerValue]];
        [self setScale:[[[element attributeForName:@"scale"] stringValue] integerValue]];
        
        [self setData:[NSData dataWithBase64EncodedString:[element stringValue]]];
    
    }
    return self;
}

-(void)dealloc {
    [self setData:nil];
    [super dealloc];
}

-(NSString *)description {
    
    return [NSString stringWithFormat:@"%@: Layout for scale %d in part %d", [super description], [self scale], [self part]];
    
}

-(NSXMLElement *)xmlElement {
    
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"xs1:layout"];
    
    [element addAttribute:[NSXMLNode attributeWithName:@"part" stringValue:[NSString stringWithFormat:@"%d", [self part]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scale" stringValue:[NSString stringWithFormat:@"%d", [self scale]]]];
    
    [element setStringValue:[[self data] base64Encoding]];
    
    return [element autorelease];
    
}

@end

