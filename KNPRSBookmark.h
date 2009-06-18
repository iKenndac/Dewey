//
//  KNPRSBookmark.h
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KNPRSBookmark : NSObject {

    NSDate *date;
    NSString  *name;
    NSInteger page;
    NSInteger pageOffset;
    NSInteger totalPages;
    NSInteger part;
    NSInteger scale;
    
}

-(id)initWithXMLElement:(NSXMLElement *)element;

@property (retain) NSDate *date;
@property (retain) NSString *name;
@property NSInteger page;
@property NSInteger pageOffset;
@property NSInteger totalPages;
@property NSInteger part;
@property NSInteger scale;

-(NSXMLElement *)xmlElement;

@end
