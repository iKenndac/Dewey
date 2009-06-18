//
//  KNPRSPlaylist.m
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import "KNPRSPlaylist.h"
#import "KNPRSBook.h"

@implementation KNPRSPlaylist

@synthesize title;
@synthesize playlistId;
@synthesize sourceId;
@synthesize uuid;
@synthesize books;

-(id)init {
    
    if (self = [super init]) {
        
        //create a new UUID
        CFUUIDRef	uuidObj = CFUUIDCreate(nil);
        //get the string representation of the UUID
        NSString	*newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        [self setUuid:[newUUID autorelease]];
        [self setTitle:@"New Collection"];
        [self setBooks:[NSMutableArray array]];
        
    }
    return self;
}

-(id)initWithXMLElement:(NSXMLElement *)element books:(NSArray *)sourceBooks {
 
    if (self = [self init]) {
        [self setTitle:[[element attributeForName:@"title"] stringValue]];
        [self setUuid:[[element attributeForName:@"uuid"] stringValue]];
        [self setSourceId:[[[element attributeForName:@"sourceid"] stringValue] integerValue]];
        [self setPlaylistId:[[[element attributeForName:@"id"] stringValue] integerValue]];
        
        NSArray *bookElements = [element elementsForName:@"xs1:item"];
        
        NSMutableArray *playlistBooks = [[NSMutableArray alloc] init];
        
        for (NSXMLElement *bookElement in bookElements) {
         
            NSInteger bookId = [[[bookElement attributeForName:@"id"] stringValue] integerValue];
            
            for (KNPRSBook *book in sourceBooks) {
                if ([book bookId] == bookId) {
                    [playlistBooks addObject:book];
                    break;
                }
            }
            
        }
        
        [self setBooks:[playlistBooks autorelease]];
        
    }
    return self;
}

-(void)removeBooks:(NSArray *)someBooks {

	NSMutableArray *booksThatMadeIt = [NSMutableArray array];
	
	for (KNPRSBook *book in [self books]) {
		if (![someBooks containsObject:book]) {
			[booksThatMadeIt addObject:book];
		}
	}
	
	[self setBooks:[NSArray arrayWithArray:booksThatMadeIt]];
	
}

-(void)dealloc {
    
    [self setTitle:nil];
    [self setUuid:nil];
    [self setBooks:nil];
    
    [super dealloc];
}

-(NSImage *)icon {
    return [NSImage imageNamed:@"CopyAudioBook"];
}

-(BOOL)canReorder {
    return YES;
}

-(NSString *)description {
    
    return [NSString stringWithFormat:@"%@: %@ %@", [super description], [self title], [self books]];
    
}

-(NSXMLElement *)xmlElement {
    
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"xs1:playlist"];
    
    [element addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:[self title]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"sourceid" stringValue:[NSString stringWithFormat:@"%d", [self sourceId]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%d", [self playlistId]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"uuid" stringValue:[self uuid]]];
    
    for (KNPRSBook *book in [self books]) {
            
        NSXMLElement *playlistEntry = [[NSXMLElement alloc] initWithName:@"xs1:item"];
        
        [playlistEntry addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%d", [book bookId]]]];
        
        [element addChild:[playlistEntry autorelease]];
        
    }
    
    return [element autorelease];
}


@end
