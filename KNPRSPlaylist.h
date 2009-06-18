//
//  KNPRSPlaylist.h
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol KNPRSBookProvider <NSObject>

-(BOOL)canReorder;
@property (readwrite, nonatomic, retain) NSArray *books;
-(NSString *)title;
-(NSImage *)icon;

@end



@interface KNPRSPlaylist : NSObject <KNPRSBookProvider> {
    
    NSString *title;
    NSInteger playlistId;
    NSInteger sourceId;
    NSString *uuid;
    
    NSMutableArray *books;
    
}

-(id)initWithXMLElement:(NSXMLElement *)element books:(NSArray *)sourceBooks;

@property (readwrite, nonatomic, copy) NSString *title;
@property NSInteger playlistId;
@property NSInteger sourceId;
@property (readwrite, nonatomic, copy) NSString *uuid;
@property (readwrite, nonatomic, retain) NSArray *books;

-(void)removeBooks:(NSArray *)someBooks;

-(NSXMLElement *)xmlElement;

@end
