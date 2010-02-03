//
//  KNDeweyRTFImporter.m
//  Dewey
//
//  Created by Daniel Kennett on 16/09/2009.
//  Copyright 2009 KennettNet Software, Limited. All rights reserved.
//

#import "KNDeweyRTFImporter.h"


@implementation KNDeweyRTFImporter

+(NSSet *)formatFileExtensions {
	return [NSSet setWithObjects:@"rtf", nil];
}

+(NSString *)formatName {
	return @"RTF";
}

+(NSString *)formatMimeType {
	return @"application/rtf";
}

@end
