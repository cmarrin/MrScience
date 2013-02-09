//
//  NumberConverter.h
//  MrScience
//
//  Created by Chris Marrin on 2/14/10.
//  Copyright 2010 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

// Conversions:
//
//  Length: m, km, cm, mm, mi, yd, ft, in
//  Weight: kg, g, mg, lb, oz
//  Volume: cu-m, cu-km, cc, cu-mm, l, pt, qt, gal, cup, fl-oz, tbsp, tsp, cu-mi, cu-yd, cu-ft, cu-in
//  Area: sq-m, sq-km, sq-cm, sq-mm, sq-mi, sq-yd, sq-ft, sq-in, acre
//  Temperature: degreesC, degreesF
//  Angle: degrees, radians
//  Time: hours, hours.minutes/seconds
//  Vectors: rectangular, polar

@interface NumberConverter : NSObject {
    // This is an array of arrays. the first dimension is the ConversionClass
    // The second is a dictionary with two arrays: title of each conversion and
    // multiplier from first entry to each of the others.
    NSArray* m_conversions;
}

- (NSArray*)conversionTypes;
- (NSArray*)conversionsForClass:(int) clas index:(int) indx;
- (void)multiplierForClass:(int) clas fromString:(NSString**) fromString forFromIndex:(int) fromIndex toString:(NSString**) toString forToIndex:(int) toIndex;
- (NSString*)stringForConversionWithClass:(int) clas index:(int) indx;
- (int)classForUnitString:(NSString*) units;
- (int)indexForUnitString:(NSString*) units;

- (NSString*) toDegCProgram;
- (NSString*) toDegFProgram;
- (NSString*) toRadProgram;
- (NSString*) toDegProgram;
- (NSString*) toHMSProgram;
- (NSString*) toHProgram;
- (NSString*) toPolarProgram;
- (NSString*) toRectProgram;

@end
