//
//  NumberConverter.m
//  MrScience
//
//  Created by Chris Marrin on 2/14/10.
//  Copyright 2010 Apple. All rights reserved.
//

#import "NumberConverter.h"


@implementation NumberConverter

static NSDictionary* makeConversionEntry(NSString* clas, NSArray* titles, NSArray* multipliers)
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            clas, @"class", 
            titles, @"titles", 
            multipliers, @"multipliers", 
            nil];
}

static NSArray* makeStringArray(NSString* first, ...)
{
    va_list ap;
    va_start(ap, first);
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSString* s = first; s; s = va_arg(ap, NSString*))
        [array addObject:s];
        
    return array;
}

- (id)init
{
    [super init];
    
    // Setup conversions list
    m_conversions = [[NSArray arrayWithObjects:
        makeConversionEntry(@"Length", 
                            makeStringArray(@"m", @"km", @"cm", @"mm", @"mi", @"yd", @"ft", @"in", nil),
                            makeStringArray(@"1", @"0.001", @"100", @"1000", @"0.0006213712", @"1.093613", @"3.280839895", @"39.3700787401574803149606299212598", nil)),
        makeConversionEntry(@"Weight", 
                            makeStringArray(@"g", @"kg", @"mg", @"lb", @"oz", nil),
                            makeStringArray(@"1", @"0.001", @"1000", @"0.002205", @"0.03527", nil)),
        makeConversionEntry(@"Volume", 
                            makeStringArray(@"m³", @"cc", @"mm³", @"liter", @"pint", @"qt", @"gal", @"cup", 
                                            @"fl-oz", @"tbsp", @"tsp", @"yd³", @"ft³", @"in³", nil),
                            makeStringArray(@"1", @"1e6", @"1e9", @"1000", @"2113", @"908.1", @"227", @"4227", 
                                            @"33810", @"67630", @"202900", @"1.308", @"35.31", @"61020", nil)),
        makeConversionEntry(@"Area", 
                            makeStringArray(@"m²", @"km²", @"cm²", @"mm²", @"mi²", @"yd²", @"ft²", @"in²", @"acre", nil),
                            makeStringArray(@"1", @"1e-6", @"10000", @"1e6", @"3.861e-7", @"1.196", @"10.76", @"1550", @"0.0002471", nil)),
        makeConversionEntry(@"Speed", 
                            makeStringArray(@"m/s", @"cm/s", @"kph", @"fps", @"mph", @"knot", @"mach", nil),
                            makeStringArray(@"1", @"100", @"3.6", @"3.280839895", @"2.2369362921", @"1.9438444925", @"0.003389297", nil)),
        nil] retain];
        
    return self;
}

- (NSArray*)conversionTypes
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSDictionary* dictionary in m_conversions)
        [array addObject:[dictionary objectForKey:@"class"]];
    return [array autorelease];
}

// Given the passed index into the fromConversions list, give back the toConversions list
- (NSArray*)conversionsForClass:(int) clas index:(int) indx
{
    return [[m_conversions objectAtIndex:clas] objectForKey:@"titles"];
}

- (void)multiplierForClass:(int) clas fromString:(NSString**) fromString forFromIndex:(int) fromIndex 
                                      toString:(NSString**) toString forToIndex:(int) toIndex
{
    NSArray* multipliers = [[m_conversions objectAtIndex:clas] objectForKey:@"multipliers"];
    *fromString = [multipliers objectAtIndex:fromIndex];
    *toString = [multipliers objectAtIndex:toIndex];
}

- (NSString*)stringForConversionWithClass:(int) clas index:(int) indx
{
    return [[[m_conversions objectAtIndex:clas] objectForKey:@"titles"] objectAtIndex:indx];
}

- (int)classForUnitString:(NSString*) units
{
    int i = 0;
    for (NSDictionary* entry in m_conversions) {
        for (NSString* title in [entry objectForKey:@"titles"]) {
            if ([title isEqualToString:units])
                return i;
        }
        ++i;
    }
    
    return -1;
}

- (int)indexForUnitString:(NSString*) units
{
    for (NSDictionary* entry in m_conversions) {
        int i = 0;
        for (NSString* title in [entry objectForKey:@"titles"]) {
            if ([title isEqualToString:units])
                return i;
            ++i;
        }
    }
    
    return -1;
}

- (NSString*) toDegCProgram
{
    return @"32; SUB; 5; MUL; 9; DIV";
}

- (NSString*) toDegFProgram
{
    return @"9; MUL; 5; DIV; 32; ADD";
}

- (NSString*) toRadProgram
{
    return @"360; DIV; PI; MUL; 2; MUL";
}

- (NSString*) toDegProgram
{
    return @"PI; DIV; 2; DIV; 360; MUL";
}

- (NSString*) toHMSProgram
{
    return @"ENTER; TRUNC; EXCH; FRAC; 60; MUL; ENTER; TRUNC;"
            "100; DIV; EXCH; FRAC; 60; MUL; 10000; DIV; ADD; ADD";
}

- (NSString*) toHProgram
{
    return @"ENTER; TRUNC; EXCH; FRAC; 100; MUL; ENTER; TRUNC; EXCH; FRAC; 36; DIV; EXCH; 60; DIV; ADD; ADD";
}

- (NSString*) toPolarProgram
{
    return @"ENTER; ROLL_DN; ROLL_DN; EXCH; ROLL_DN; ENTER; ROLL_UP; DIV; ARCTAN; ROLL_DN; X_SQUARED; EXCH; X_SQUARED; ADD; SQRT; EXCH; ROLL_DN; EXCH";
}

- (NSString*) toRectProgram
{
    return @"ENTER; SIN; EXCH; COS; ROLL_DN; ROLL_DN; EXCH; ROLL_DN; ENTER; ROLL_DN; MUL; ROLL_DN; EXCH; ROLL_DN; MUL; EXCH";
}

@end
