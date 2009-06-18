//
//  KNPRSDevice.h
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNPRSBook.h"
#import "KNPRSPlaylist.h"


@interface KNPRSDevice : NSObject <KNPRSBookProvider> {

    NSArray *books;
    NSArray *playlists;
    NSString *volumePath;
}

-(id)initWithPathToReaderVolume:(NSString *)path;
-(id)initWithXMLDocument:(NSXMLDocument *)doc;

@property (nonatomic, retain, readwrite) NSArray *books;
@property (nonatomic, retain, readwrite) NSArray *playlists;
@property (nonatomic, copy, readwrite) NSString *volumePath;

+(NSString *)databasePathFromVolumePath:(NSString *)volume;

-(KNPRSPlaylist *)createPlaylist;
-(void)addPlaylist:(KNPRSPlaylist *)playlist;
-(void)removePlaylist:(KNPRSPlaylist *)playlist;

-(KNPRSBook *)bookWithId:(NSInteger)bookId;

-(NSInteger)performIntegrityCheck;
-(void)constructFromXmlDocument:(NSXMLDocument *)doc;
-(NSXMLDocument *)xmlDocument;

@end
