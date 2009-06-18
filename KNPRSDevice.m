//
//  KNPRSDevice.m
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import "KNPRSDevice.h"


@implementation KNPRSDevice

static NSString *deviceKVOContext = @"deviceKVO";

-(id)init {
    return [self initWithXMLDocument:nil];
}

-(id)initWithPathToReaderVolume:(NSString *)path {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:[KNPRSDevice databasePathFromVolumePath:path]] 
                                                         options:0
                                                           error:nil];
        
        if (doc) {
            if (self = [self initWithXMLDocument:[doc autorelease]]) {
            
                [self setVolumePath:path];
            }
            return self;
        }
        return nil;
        
    } else {
        return nil;
    }
    
}

-(id)initWithXMLDocument:(NSXMLDocument *)doc {
 
    if (self = [super init]) {
        
        [self addObserver:self forKeyPath:@"books" options:0 context:deviceKVOContext];
        [self addObserver:self forKeyPath:@"playlists" options:0 context:deviceKVOContext];
        
        // Add observers before constructing books and playlists, so the integrity checks 
        // automatically get performed. This way, there's a chance we'll fix a "broken"
        // database simply by opening and saving it.
        
		[self setBooks:[NSArray array]];
		[self setPlaylists:[NSArray array]];
		
        if (doc) {
            [self constructFromXmlDocument:doc];
        }
    } 
    return self;
}

@synthesize books;
@synthesize playlists;
@synthesize volumePath;


-(void)dealloc {
    [self setBooks:nil];
    [self setPlaylists:nil];
    
    [super dealloc];
}

-(KNPRSBook *)bookWithId:(NSInteger)bookId {
 
    for (KNPRSBook *book in [self books]) {
        if ([book bookId] == bookId) {
            return book;
        }
    }
    
    return nil;
}

-(KNPRSPlaylist *)createPlaylist {
    
    KNPRSPlaylist *newPlaylist = [[KNPRSPlaylist alloc] init];
    
    [self setPlaylists:[[self playlists] arrayByAddingObject:[newPlaylist autorelease]]];
    
    return newPlaylist;
}

-(void)addPlaylist:(KNPRSPlaylist *)playlist {
	[self setPlaylists:[[self playlists] arrayByAddingObject:playlist]];
}

-(void)removePlaylist:(KNPRSPlaylist *)playlist {
 
    NSMutableArray *newPlaylists = [NSMutableArray arrayWithCapacity:[[self playlists] count] - 1];
    
    for (KNPRSPlaylist *existingPlaylist in [self playlists]) {
        if (existingPlaylist != playlist) {
            [newPlaylists addObject:existingPlaylist];
        }
    }
    
    [self setPlaylists:newPlaylists];  
    
}

#pragma mark -
#pragma mark Book Provider Protocol

-(BOOL)canReorder {
    return NO;
}

-(NSString *)title {
    return @"All Books";
}

-(NSImage *)icon {
    return [NSImage imageNamed:@"Book"];
}

#pragma mark -
#pragma mark KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == deviceKVOContext) {
        if ([keyPath isEqualToString:@"books"] || [keyPath isEqualToString:@"playlists"]) {
            [self performIntegrityCheck];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



#pragma mark -
#pragma mark Database Management

+(NSString *)databasePathFromVolumePath:(NSString *)volume {
	
    return [[[volume stringByAppendingPathComponent:@"database"] 
			 stringByAppendingPathComponent:@"cache"] 
			stringByAppendingPathComponent:@"media.xml"];
    
}

-(NSInteger)performIntegrityCheck {
    
    // The record ids in the Reader's 
    // database need to be incremental from 0, so if we
    // remove a book or playlist from the middle, we need to 
    // make sure they still match this rule.
    
    NSInteger currentId = 2; // Start from 2, as 0 and 1 are reserved for things we don't manage
    
    for (KNPRSBook *book in [self books]) {
        [book setBookId:currentId];
        currentId++;
    }
    
    for (KNPRSPlaylist *playlist in [self playlists]) {
        [playlist setPlaylistId:currentId];
        currentId++;
    }
    
    // Return currentId, which is now one higher than the ids used. Handily, this is a
    // required piece of information in the database.
    
    return currentId;
}

-(void)constructFromXmlDocument:(NSXMLDocument *)doc { 
 
    NSMutableArray *booksArray = [[NSMutableArray alloc] init];
    NSMutableArray *playlistsArray = [[NSMutableArray alloc] init];
    
    for (NSXMLElement *element in [[doc rootElement] elementsForName:@"records"]) {
        for (NSXMLElement *bookElement in [element elementsForName:@"xs1:text"]) {
            
            KNPRSBook *book = [[KNPRSBook alloc] initWithXMLElement:bookElement];
            
            if (book) {
                [booksArray addObject:[book autorelease]];
            }
        }
        
        for (NSXMLElement *playlistElement in [element elementsForName:@"xs1:playlist"]) {
            
            KNPRSPlaylist *playlist = [[KNPRSPlaylist alloc] initWithXMLElement:playlistElement books:booksArray];
            
            if (playlist) {
                [playlistsArray addObject:[playlist autorelease]];
            }
        }
        
    }
    
    [self setBooks:[booksArray autorelease]];
    [self setPlaylists:[playlistsArray autorelease]];
    
}

-(NSXMLDocument *)xmlDocument {
    
    NSInteger nextID = [self performIntegrityCheck];
 
    NSXMLElement *rootElement = [[NSXMLElement alloc] initWithName:@"xdbLite"];
    [rootElement addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://xscool.net/xdb/1"]];
    [rootElement addAttribute:[NSXMLNode attributeWithName:@"xmlns:xs1" stringValue:@"http://www.kinoma.com/FskCache/1"]];
    [rootElement addAttribute:[NSXMLNode attributeWithName:@"default" stringValue:@"string"]];
    [rootElement addAttribute:[NSXMLNode attributeWithName:@"nextID" stringValue:[NSString stringWithFormat:@"%d", nextID]]];
    
    // Indexes
    
    NSXMLElement *indexesElement = [[NSXMLElement alloc] initWithName:@"indexes"];
    
    NSXMLElement *indexSource = [[NSXMLElement alloc] initWithName:@"index"];
    [indexSource setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexSource", @"name", @"string,unique", @"type", nil]];
    [indexesElement addChild:[indexSource autorelease]];
                                            
    NSXMLElement *indexArtist = [[NSXMLElement alloc] initWithName:@"index"];
    [indexArtist setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexArtist", @"name", @"string", @"type", nil]];
    [indexesElement addChild:[indexArtist autorelease]];

    NSXMLElement *indexAlbum = [[NSXMLElement alloc] initWithName:@"index"];
    [indexAlbum setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexAlbum", @"name", @"string", @"type", nil]];
    [indexesElement addChild:[indexAlbum autorelease]];
    
    NSXMLElement *indexDate = [[NSXMLElement alloc] initWithName:@"index"];
    [indexDate setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexDate", @"name", @"number", @"type", nil]];
    [indexesElement addChild:[indexDate autorelease]];
    
    NSXMLElement *indexDateTime = [[NSXMLElement alloc] initWithName:@"index"];
    [indexDateTime setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexDateTime", @"name", @"number", @"type", nil]];
    [indexesElement addChild:[indexDateTime autorelease]];
    
    NSXMLElement *indexDimensions = [[NSXMLElement alloc] initWithName:@"index"];
    [indexDimensions setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexDimensions", @"name", @"integer", @"type", nil]];
    [indexesElement addChild:[indexDimensions autorelease]];
    
    NSXMLElement *indexDuration = [[NSXMLElement alloc] initWithName:@"index"];
    [indexDuration setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexDuration", @"name", @"integer", @"type", nil]];
    [indexesElement addChild:[indexDuration autorelease]];
    
    NSXMLElement *indexGenre = [[NSXMLElement alloc] initWithName:@"index"];
    [indexGenre setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexGenre", @"name", @"string", @"type", nil]];
    [indexesElement addChild:[indexGenre autorelease]];
    
    NSXMLElement *indexTitle = [[NSXMLElement alloc] initWithName:@"index"];
    [indexTitle setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexTitle", @"name", @"string", @"type", nil]];
    [indexesElement addChild:[indexTitle autorelease]];
    
    NSXMLElement *indexPlaylist = [[NSXMLElement alloc] initWithName:@"index"];
    [indexPlaylist setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexPlaylist", @"name", @"string", @"type", nil]];
    [indexesElement addChild:[indexPlaylist autorelease]];
    
    NSXMLElement *indexSize = [[NSXMLElement alloc] initWithName:@"index"];
    [indexSize setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexSize", @"name", @"integer", @"type", nil]];
    [indexesElement addChild:[indexSize autorelease]];
    
    NSXMLElement *indexPath = [[NSXMLElement alloc] initWithName:@"index"];
    [indexPath setAttributesAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"indexPath", @"name", @"string,sensitive", @"type", nil]];
    [indexesElement addChild:[indexPath autorelease]];
    
    [rootElement addChild:[indexesElement autorelease]];
    
    // Records
    
    NSXMLElement *recordsElement = [[NSXMLElement alloc] initWithName:@"records"];
    
    // library
    
    NSXMLElement *libraryElement = [[NSXMLElement alloc] initWithName:@"xs1:library"];
    
    [libraryElement addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:@"0"]];
    [libraryElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@"CCCCCCCCCCCC-CCCC-CCCC-CCCCCCCCCCCC"]];
    [libraryElement addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:@"Library"]];
    [libraryElement addChild:[NSXMLElement elementWithName:@"xs1:accepted" stringValue:@"true"]];
    
    [recordsElement addChild:[libraryElement autorelease]];
    
    // watchSpecial
    
    NSXMLElement *watchSpecialElement = [[NSXMLElement alloc] initWithName:@"xs1:watchSpecial"];
    
    [watchSpecialElement addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:@"1"]];
    [watchSpecialElement addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@"mediaPath"]];
    [watchSpecialElement addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:@"kbook"]];
    [watchSpecialElement addChild:[NSXMLElement elementWithName:@"xs1:accepted" stringValue:@"true"]];
    
    [recordsElement addChild:[watchSpecialElement autorelease]];
    
    // Books
    
    for (KNPRSBook *book in [self books]) {
        [recordsElement addChild:[book xmlElement]];
    }
    
    // Playlists
    
    for (KNPRSPlaylist *playlist in [self playlists]) {
        [recordsElement addChild:[playlist xmlElement]];
    }
    
    [rootElement addChild:[recordsElement autorelease]];
    
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithRootElement:[rootElement autorelease]];
    [doc setVersion:@"1.0"];
    [doc setCharacterEncoding:@"UTF-8"];
    
    return [doc autorelease];
    
}

@end
