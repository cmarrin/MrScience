//
//  Number.h
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  DECNUMDIGITS 34
#define MAXDECSTRINGSIZE DECNUMDIGITS + 14
#define MAXMANTISSA 12
#define MAXEXPONENT 3

typedef enum { DEC, HEX, BIN, OCT } BaseType;
typedef enum { FIX, SCI, ENG, ALL } DispType;
typedef enum { ST_OK, ST_DIVIDE_BY_ZERO, ST_OVERFLOW, ST_UNDERFLOW, ST_INVALID, ST_MISSING_PARAM } StatusType;

struct decNumber;

@interface Number : NSObject {
    struct decNumber* m_number;
}

+ (StatusType) lastStatus;

+ (Number*)number;
+ (Number*)numberWithNumber:(Number*) number;
+ (Number*)numberWithString:(NSString*) string inBase:(BaseType) base;
+ (Number*)numberWithUInt64:(uint64_t) integer;
+ (Number*)numberWithDouble:(double) number;

- (Number*)init;
- (Number*)initWithNumber:(Number*) string;
- (Number*)initWithString:(NSString*) string inBase:(BaseType) base;
- (Number*)initWithUInt64:(uint64_t) integer;
- (Number*)initWithDouble:(double) number;

- (NSString*)stringInBase:(BaseType) base format:(DispType) disp precision:(int) significantDigits;
- (uint64_t) uInt64Value;
- (double)doubleValue;

- (void)add:(Number*) rightOperand;
- (void)subtract:(Number*) rightOperand;
- (void)multiply:(Number*) rightOperand;
- (void)divide:(Number*) rightOperand;
- (void)power:(Number*) rightOperand;
- (void)abs;
- (void)squareRoot;
- (void)exp;
- (void)ln;
- (void)log;

- (BOOL)zero;
- (BOOL)negative;
- (BOOL)nan;
- (BOOL)infinite;

- (int)compare:(Number*) rightOperand;

- (void) roundWithSignificantDigits:(int) significantDigits;
- (void) trunc;
- (void) frac;
- (void) rand;
- (void) seed;

@end
