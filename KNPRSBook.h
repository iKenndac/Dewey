//
//  KNPRSBook.h
//  PRS Reader
//
//  Created by Daniel Kennett on 06/05/2009.
//  Copyright 2009 KennettNet Software Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KNPRSBook : NSObject {
    
    NSString *author;
    NSInteger currentPage;
    NSInteger pageOffset;
    NSInteger part;
    NSInteger scale;
    NSInteger sourceId;
    NSInteger bookId;
    NSDate *date;
    NSString *mimeType;
    NSString *relativePath;
    NSUInteger fileSize;
    NSString *title;
    NSString *titleForSorting;
    NSArray *history;
    NSArray *bookmarks;
    NSArray *layouts;
    NSImage *thumbnailImage;
    NSData *thumbnailImageData;
    
}

-(id)initWithXMLElement:(NSXMLElement *)element;

@property (readwrite, nonatomic, copy) NSString *author;
@property NSInteger currentPage;
@property NSInteger pageOffset;
@property NSInteger part;
@property NSInteger scale;
@property NSInteger sourceId;
@property NSInteger bookId;
@property (readwrite, nonatomic, retain) NSDate *date;
@property (readwrite, nonatomic, copy) NSString *mimeType;
@property (readwrite, nonatomic, copy) NSString *relativePath;
@property NSUInteger fileSize;
@property (readwrite, nonatomic, copy) NSString *title;
@property (readwrite, nonatomic, copy) NSString *titleForSorting;
@property (readwrite, nonatomic, retain) NSArray *history;
@property (readwrite, nonatomic, retain) NSArray *bookmarks;
@property (readwrite, nonatomic, retain) NSArray *layouts;
@property (readwrite, nonatomic, retain) NSData *thumbnailImageData;

-(NSImage *)thumbnailImage;
-(NSXMLElement *)xmlElement;

@end
