//
//  KNDeweyBookFormatImporter.h
//  Dewey
//
//  Created by Daniel Kennett on 14/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KNPRSDevice.h"

#define kThumbnailMaximumSize 80.0

static NSString * const kImporterUserCancelledError = @"com.kennettnet.Dewey.importer.userCancelled";
static NSString * const kImporterInvalidInputFileError = @"com.kennettnet.Dewey.importer.invalidFile";
static NSString * const kImporterCopyToDeviceFailed = @"com.kennettnet.Dewey.importer.copyFailed";

@protocol KNDeweyBookFormatImporter;


@protocol KNDeweyBookFormatImporterDelegate 

-(void)importer:(id <KNDeweyBookFormatImporter>)anImporter importOfFileAtURL:(NSURL *)fileURL failedWithError:(NSError *)error;
-(void)importer:(id <KNDeweyBookFormatImporter>)anImporter importOfFileAtURL:(NSURL *)fileURL succeededWithBook:(KNPRSBook *)aBook;

@end


@protocol KNDeweyBookFormatImporter <NSObject>

+(NSSet *)formatFileExtensions;
+(NSString *)formatName;
+(NSString *)formatMimeType;

@property (nonatomic, assign, readwrite) __weak id <KNDeweyBookFormatImporterDelegate> delegate;

-(void)importFromFileAtURL:(NSURL *)fileURL inWindow:(NSWindow *)aWindow toDevice:(KNPRSDevice *)aDevice;

@end
