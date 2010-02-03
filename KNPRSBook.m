//
//  KNPRSBook.m
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import "KNPRSBook.h"
#import "KNPRSLayout.h"
#import "NSData+Base64.h"

@implementation KNPRSBook

@synthesize author;
@synthesize currentPage;
@synthesize pageOffset;
@synthesize part;
@synthesize scale;
@synthesize sourceId;
@synthesize bookId;
@synthesize date;
@synthesize mimeType;
@synthesize relativePath;
@synthesize fileSize;
@synthesize title;
@synthesize titleForSorting;
@synthesize history;
@synthesize bookmarks;
@synthesize layouts;
@synthesize thumbnailImageData;

-(id)init {
    
    if (self = [super init]) {
        
        
    }
    return self;
}

-(id)initWithXMLElement:(NSXMLElement *)element {
 
    if (self = [self init]) {
        
        // The node should be an xs1:text node. 
        
        [self setAuthor:[[element attributeForName:@"author"] stringValue]];
        [self setTitle:[[element attributeForName:@"title"] stringValue]];
        [self setTitleForSorting:[[element attributeForName:@"titleSorter"] stringValue]];
        [self setRelativePath:[[element attributeForName:@"path"] stringValue]];
        [self setMimeType:[[element attributeForName:@"mime"] stringValue]];
        [self setFileSize:[[[element attributeForName:@"size"] stringValue] integerValue]];
        [self setPageOffset:[[[element attributeForName:@"pageOffset"] stringValue] integerValue]];
        [self setCurrentPage:[[[element attributeForName:@"page"] stringValue] integerValue]];
        [self setPart:[[[element attributeForName:@"part"] stringValue] integerValue]];
        [self setScale:[[[element attributeForName:@"scale"] stringValue] integerValue]];
        [self setSourceId:[[[element attributeForName:@"sourceid"] stringValue] integerValue]];
        [self setBookId:[[[element attributeForName:@"id"] stringValue] integerValue]];
        [self setDate:[[[NSCalendarDate alloc] initWithString:[[element attributeForName:@"date"] stringValue] 
                                               calendarFormat:@"%a, %d %b %Y %H:%M:%S %Z"] autorelease]];

        
        for (NSXMLElement *thumbnailElement in [element elementsForName:@"xs1:thumbnail"]) {
            for (NSXMLElement *jpgElement in [thumbnailElement elementsForName:@"xs1:jpeg"]) {
                [self setThumbnailImageData:[NSData dataWithBase64EncodedString:[jpgElement stringValue]]];
            }
        }
        
        NSMutableArray *historyBookmarks = [[NSMutableArray alloc] init];
        
        for (NSXMLElement *historyElement in [element elementsForName:@"xs1:history"]) {
            for (NSXMLElement *bookmarkElement in [historyElement elementsForName:@"xs1:bookmark"]) {
                
                KNPRSBookmark *bookmark = [[KNPRSBookmark alloc] initWithXMLElement:bookmarkElement];
                
                if (bookmark) {
                    [historyBookmarks addObject:bookmark];
                }
				
				[bookmark release];
				bookmark = nil;
            }
        }
        
        [self setHistory:[historyBookmarks autorelease]];
        
        NSMutableArray *bookBookmarks = [[NSMutableArray alloc] init];
        
        for (NSXMLElement *bookmarkChildElement in [element elementsForName:@"xs1:bookmarks"]) {
            for (NSXMLElement *bookmarkElement in [bookmarkChildElement elementsForName:@"xs1:bookmark"]) {
                
                KNPRSBookmark *bookmark = [[KNPRSBookmark alloc] initWithXMLElement:bookmarkElement];
                
                if (bookmark) {
                    [bookBookmarks addObject:bookmark];
                }
				
				[bookmark release];
            }
        }
        
        [self setBookmarks:[bookBookmarks autorelease]];
        
        NSMutableArray *bookLayouts = [[NSMutableArray alloc] init];
        
        for (NSXMLElement *layoutChildElement in [element elementsForName:@"xs1:layouts"]) {
            for (NSXMLElement *layoutElement in [layoutChildElement elementsForName:@"xs1:layout"]) {
                
                KNPRSLayout *layout = [[KNPRSLayout alloc] initWithXMLElement:layoutElement];
                
                if (layout) {
                    [bookLayouts addObject:layout];
                }
				
				[layout release];
				layout = nil;
            }
        }
        
        [self setLayouts:[bookLayouts autorelease]];
    }
    
    return self;
}

-(void)dealloc {
    
    [self setAuthor:nil];
    [self setDate:nil];
    [self setMimeType:nil];
    [self setRelativePath:nil];
    [self setTitle:nil];
    [self setTitleForSorting:nil];
    [self setBookmarks:nil];
    [self setHistory:nil];
    [self setLayouts:nil];
    if (thumbnailImage) {
        [thumbnailImage release];
        thumbnailImage = nil;
    }
    [self setThumbnailImageData:nil];
    
    [super dealloc];
}

-(NSString *)description {
 
    return [NSString stringWithFormat:@"%@: %@ by %@", [super description], [self title], [self author]];
    
}

-(NSImage *)thumbnailImage {
 
    if (!thumbnailImage) {
        if ([self thumbnailImageData]) {
            thumbnailImage = [[NSImage alloc] initWithData:[self thumbnailImageData]];
        }
    }
    
    return thumbnailImage;    
}

-(NSXMLElement *)xmlElement {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%a, %d %b %Y %H:%M:%S GMT" allowNaturalLanguage:NO];
    
    NSXMLElement *element = [[NSXMLElement alloc] initWithName:@"xs1:text"];
    
    // Basic attributes
    
    [element addAttribute:[NSXMLNode attributeWithName:@"author" stringValue:[self author]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"page" stringValue:[NSString stringWithFormat:@"%d", [self currentPage]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"pageOffset" stringValue:[NSString stringWithFormat:@"%d", [self pageOffset]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"part" stringValue:[NSString stringWithFormat:@"%d", [self part]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scale" stringValue:[NSString stringWithFormat:@"%d", [self scale]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"sourceid" stringValue:[NSString stringWithFormat:@"%d", [self sourceId]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%d", [self bookId]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"date" stringValue:[formatter stringFromDate:[self date]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"mime" stringValue:[self mimeType]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"path" stringValue:[self relativePath]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%d", [self fileSize]]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:[self title]]];
    
    if ([self titleForSorting]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"titleSorter" stringValue:[self titleForSorting]]];
    }
    
    // Bookmarks
    
    if ([[self bookmarks] count] > 0) {
        
        NSXMLElement *bookmarksElement = [[NSXMLElement alloc] initWithName:@"xs1:bookmarks"];
        
        for (KNPRSBookmark *bookmark in [self bookmarks]) {
            [bookmarksElement addChild:[bookmark xmlElement]];
        }
        
        [element addChild:[bookmarksElement autorelease]];
    }
    
    // History
        
    if ([[self history] count] > 0) {
     
        NSXMLElement *historyElement = [[NSXMLElement alloc] initWithName:@"xs1:history"];
        
        for (KNPRSBookmark *bookmark in [self history]) {
            [historyElement addChild:[bookmark xmlElement]];
        }
     
        [element addChild:[historyElement autorelease]];
    }
    
    // Layouts
    
    if ([[self layouts] count] > 0) {
            
        NSXMLElement *layoutsElement = [[NSXMLElement alloc] initWithName:@"xs1:layouts"];
        
        for (KNPRSLayout *layout in [self layouts]) {
            [layoutsElement addChild:[layout xmlElement]];
        }
        
        [element addChild:[layoutsElement autorelease]];
    }
    
    // Thumbnail
    
    if ([self thumbnailImageData] && [self thumbnailImage]) {
     
        NSXMLElement *thumbnailElement = [[NSXMLElement alloc] initWithName:@"xs1:thumbnail"];
        
        NSImage *thumbnail = [self thumbnailImage];
        
        [thumbnailElement addAttribute:[NSXMLNode attributeWithName:@"width" 
                                                        stringValue:[NSString stringWithFormat:@"%d", (NSInteger)[thumbnail size].width]]];
        [thumbnailElement addAttribute:[NSXMLNode attributeWithName:@"height" 
                                                        stringValue:[NSString stringWithFormat:@"%d", (NSInteger)[thumbnail size].height]]];
        
        NSXMLElement *jpgElement = [[NSXMLElement alloc] initWithName:@"xs1:jpeg"];
        [jpgElement setStringValue:[[self thumbnailImageData] base64Encoding]];
        
        [thumbnailElement addChild:[jpgElement autorelease]];
        
        [element addChild:[thumbnailElement autorelease]];
    }
    
    [formatter release];
    
    return [element autorelease];
    
}

#pragma mark -
#pragma mark UI Helpers

-(NSInteger)pages {
	
	// The amount of pages in the book isn't stored in the book, but is in the bookmarks and history. 
	
	NSInteger highestPage = 0;
	
	for (KNPRSBookmark *bookmark in [self bookmarks]) {
		if ([bookmark totalPages] > highestPage) {
			highestPage = [bookmark totalPages];
		}
	}
	
	for (KNPRSBookmark *bookmark in [self history]) {
		if ([bookmark totalPages] > highestPage) {
			highestPage = [bookmark totalPages];
		}
	}
	
	return highestPage;
}

-(NSString *)pageStatistic {

	NSInteger pages = [self pages];
	
	if ([self currentPage] > 0 && pages > 0) {
		return [NSString stringWithFormat:@"%d of %d", [self currentPage], pages];
	}
	
	// Returning nil allows bindings to do something clever, like grey out the statistic's label
	return nil;
	
}

-(NSString *)humanReadableFileSize {
	
	int sizeComparator = 1023;
	int sizeDivisor = 1024;
	
	// On 10.6, follow the base-10 convention for file sizes.
	SInt32 version = 0;
	Gestalt( gestaltSystemVersionMinor, &version );
	
	if ((version >= 6) && [[NSUserDefaults standardUserDefaults] boolForKey:@"OverrideSnowLeopardFileSizeBehavior"] == NO) {
		sizeComparator = 999;
		sizeDivisor = 1000;
	}
	
	float floatSize = (float)[self fileSize];
    if (fileSize < sizeComparator)
        return([NSString stringWithFormat:@"%1.0f bytes",fileSize]);
    floatSize = floatSize / sizeDivisor;
    if (floatSize < sizeComparator)
        return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
    floatSize = floatSize / sizeDivisor;
    if (floatSize < sizeComparator)
        return([NSString stringWithFormat:@"%1.2f MB",floatSize]);
    floatSize = floatSize / sizeDivisor;
    
    // Add as many as you like
    
    return([NSString stringWithFormat:@"%1.2f GB",floatSize]);
	
	
}

@end
