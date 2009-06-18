//
//  KNPRSBookmark.m
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import "KNPRSBookmark.h"


@implementation KNPRSBookmark

@synthesize date;
@synthesize name;
@synthesize page;
@synthesize pageOffset;
@synthesize totalPages;
@synthesize part;
@synthesize scale;

-(id)initWithXMLElement:(NSXMLElement *)element {
    
    if (self = [super init]) {
 
        [self setName:[[element attributeForName:@"name"] stringValue]];
        [self setPage:[[[element attributeForName:@"page"] stringValue] integerValue]];
        [self setPageOffset:[[[element attributeForName:@"pageOffset"] stringValue] integerValue]];
        [self setTotalPages:[[[element attributeForName:@"pages"] stringValue] integerValue]];
        [self setPart:[[[element attributeForName:@"part"] stringValue] integerValue]];
        [self setScale:[[[element attributeForName:@"scale"] stringValue] integerValue]];
        [self setDate:[[[NSCalendarDate alloc] initWithString:[[element attributeForName:@"date"] stringValue] 
                                               calendarFormat:@"%a, %d %b %Y %H:%M:%S %Z"] autorelease]];
    }
    return self;
}

-(void)dealloc {
    
    [self setDate:nil];
    [self setName:nil];
    [super dealloc];
}


-(NSString *)description {
    
    return [NSString stringWithFormat:@"%@: Page %d of %d", [super description], [self page], [self totalPages]];
    
}


-(NSXMLElement *)xmlElement {
    
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"xs1:bookmark"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%a, %d %b %Y %H:%M:%S GMT" allowNaturalLanguage:NO];
    
    [element addAttribute:[NSXMLNode attributeWithName:@"date" stringValue:[formatter stringFromDate:[self date]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:[self name]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"page" stringValue:[NSString stringWithFormat:@"%d", [self page]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"pageOffset" stringValue:[NSString stringWithFormat:@"%d", [self pageOffset]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"pages" stringValue:[NSString stringWithFormat:@"%d", [self totalPages]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"part" stringValue:[NSString stringWithFormat:@"%d", [self part]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scale" stringValue:[NSString stringWithFormat:@"%d", [self scale]]]];
    
    [formatter release];
    
    return [element autorelease];
    
}

@end
