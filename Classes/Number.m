//
//  Number.m
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Number.h"

#import "decNumber.h"

static StatusType g_lastStatus = ST_OK;

@implementation Number

+ (decContext*)sharedContext
{
    static decContext* numberContext = 0;
    if (!numberContext) {
        numberContext = malloc(sizeof(decContext));

        decContextTestEndian(0); // warn if DECLITEND is wrong
        decContextDefault(numberContext, DEC_INIT_BASE);
        decContextSetRounding(numberContext, DEC_ROUND_HALF_UP);
        numberContext->traps=0;
        numberContext->digits=DECNUMDIGITS;
        numberContext->emax = 999;
        numberContext->emin = -999;
    }
    return numberContext;
}

+ (decNumber*)twoToThe32nd
{
    static decNumber* number;
    if (!number) {
        number = malloc(sizeof(decNumber));
        decNumberFromUInt32(number, 65536);
        decNumberMultiply(number, number, number, [Number sharedContext]);
    }
    return number;
}


+ (StatusType)lastStatus
{
    if (g_lastStatus != ST_OK) {
        StatusType status = g_lastStatus;
        g_lastStatus = ST_OK;
        return status;
    }
    
    uint32_t contextStatus = decContextTestStatus([Number sharedContext], 0xFFFFFFFF);
    decContextZeroStatus([Number sharedContext]);
    
    if (contextStatus & DEC_Division_by_zero || contextStatus & DEC_Division_undefined)
        return ST_DIVIDE_BY_ZERO;
    else if (contextStatus & DEC_Invalid_operation)
        return ST_INVALID;
    else if (contextStatus & DEC_Overflow || contextStatus & DEC_Division_impossible)
        return ST_OVERFLOW;
    else if (contextStatus & DEC_Underflow)
        return ST_UNDERFLOW;
    else
        return ST_OK;
}

- (decNumber*) decNumber
{
    return m_number;
}

- (Number*)init
{
    if (!m_number)
        m_number = malloc(sizeof(decNumber));
    decNumberZero(m_number);
    g_lastStatus = ST_OK;
    return self;
}

- (void)dealloc
{
    free(m_number);
    [super dealloc];
}

+ (Number*)number
{
    return [[[Number alloc] init] autorelease];
}

+ (Number*)numberWithNumber:(Number*) number
{
    return [[[Number alloc] initWithNumber:number] autorelease];
}

+ (Number*)numberWithString:(NSString*) string inBase:(BaseType) base
{
    return [[[Number alloc] initWithString:string inBase:base] autorelease];
}

+ (Number*)numberWithUInt64:(uint64_t) integer
{
    return [[[Number alloc] initWithUInt64:integer] autorelease];
}

+ (Number*)numberWithDouble:(double) number
{
    return [[[Number alloc] initWithDouble:number] autorelease];
}

- (Number*) initWithNumber:(Number*) number
{
    if (!number)
        return self;
        
    if (!m_number)
        m_number = malloc(sizeof(decNumber));
    g_lastStatus = ST_OK;
    decNumberCopy(m_number, [number decNumber]);
    return self;
}

- (Number*) initWithDecNumber:(decNumber*) number
{
    [self init];
    decNumberCopy(m_number, number);
    return self;
}

+ (Number*)numberWithDecNumber:(decNumber*) number
{
    return [[[Number alloc] initWithDecNumber:number] autorelease];
}

- (Number*)initWithUInt64:(uint64_t) integer
{
    [self init];
    decNumber lo, hi;
    decNumberFromUInt32(&lo, (uint32_t) integer);
    decNumberFromUInt32(&hi, (uint32_t) (integer >> 32));
    decNumberMultiply(&hi, &hi, [Number twoToThe32nd], [Number sharedContext]);
    decNumberAdd(m_number, &hi, &lo, [Number sharedContext]);
    return self;
}

static uint64_t integerFromString(NSString* s, int radix)
{
    uint64_t multiplier = 1;
    uint64_t result = 0;
    uint64_t digit;
    
    for (int i = [s length] - 1; i >= 0; --i) {
        unichar c = [s characterAtIndex:i];
        if (c >= '0' && c <= '9')
            digit = c - '0';
        else if (c >= 'A' && c <= 'Z')
            digit = c - 'A' + 10;
        else
            digit = 0;
            
        if (digit >= (uint64_t) radix)
            digit = 0;
            
        result += digit * multiplier;
        multiplier *= radix;
    }
    
    return result;
}

- (Number*)initWithString:(NSString*) string inBase:(BaseType) base
{
    [self init];
    uint64_t integer = 0;
        
    switch(base) {
        case DEC:
            decNumberFromString(m_number, [string UTF8String], [Number sharedContext]);
            return self;
        case HEX:
            integer = integerFromString(string, 16);
            break;
        case BIN:
            integer = integerFromString(string, 2);
            break;
        case OCT:
            integer = integerFromString(string, 8);
            break;
    }
    
    [self initWithUInt64:integer];
    
    return self;
}

- (Number*)initWithDouble:(double) number
{
    [self init];
    char s[MAXDECSTRINGSIZE];
    sprintf(s, "%.16e", number);
    decNumberFromString(m_number, s, [Number sharedContext]);
    return self;
}

- (uint64_t) uInt64Value
{
    decNumber loNum, hiNum;
    decNumberDivideInteger(&hiNum, m_number, [Number twoToThe32nd], [Number sharedContext]);
    uint32_t hi = decNumberToUInt32(&hiNum, [Number sharedContext]);
    decNumberMultiply(&hiNum, &hiNum, [Number twoToThe32nd], [Number sharedContext]);
    decNumberSubtract(&loNum, m_number, &hiNum, [Number sharedContext]);
    uint32_t lo = decNumberToUInt32(&loNum, [Number sharedContext]);
    
    return (uint64_t) lo + (((uint64_t) hi) << 32);
}

static NSString* stringFromInteger(uint64_t integer, BaseType base)
{
    // For now we only handle BIN, OCT and HEX
    int shiftCount = (base == BIN) ? 1 : ((base == OCT) ? 3 : 4);
    uint64_t mask = (1 << shiftCount) - 1;
    
    if (integer == 0)
        return @"0";

    NSString* s = @"";
    for (int i = 0; integer; ++i) {
        char c = integer & mask;
        if (c <= 9)
            c += '0';
        else
            c += 'A' - 10;
        
        if ((base == BIN || base == HEX) && i != 0 && i % 4 == 0)
            s = [NSString stringWithFormat:@"%c %@", c, s];
        else 
            s = [NSString stringWithFormat:@"%c%@", c, s];
        integer >>= shiftCount;
    }
    
    return s;
}

- (NSString*)integerStringInBase:(BaseType) base
{
    Number* tmp = [Number numberWithNumber:self];
    [tmp abs];
    uint64_t integer = [tmp uInt64Value];
    if (decNumberIsNegative(m_number))
        integer = -integer;
        
    return stringFromInteger(integer, base);
}

static inline uint8_t digitFromMantissa(uint8_t* mantissa, int* indx, int numDigits)
{
    return (*indx >= numDigits) ? 0 : mantissa[(*indx)++];
}

static NSString* string(decNumber* decNum, BaseType base, DispType disp, int significantDigits)
{
    Number* number = [Number numberWithDecNumber:decNum];
    if ([number nan])
        return @"NaN";
        
    if ([number infinite]) {
        if ([number negative])
            return @"-∞";
        else
            return @"∞";
    }
    
    if (base != DEC) {
        // Handle the other bases. The number must be an integer
        // and we truncate the fraction part, so there's no need
        // for rounding
        Number* tmp = [Number numberWithNumber:number];
        [tmp abs];
        uint64_t integer = [tmp uInt64Value];
        if ([number negative])
            integer = -integer;
            
        return stringFromInteger(integer, base);
    }
    
    // Do an initial rounding to see see how many significant digits we have
    [Number sharedContext]->digits = MAXMANTISSA + 1;
    decNumber roundedNumber;
    decNumberReduce(&roundedNumber, decNum, [Number sharedContext]);
    [Number sharedContext]->digits = DECNUMDIGITS;    
    
    // Get the exp to determine home many digits to the left of the decimal
    decNumber expNum;
    int exponent = 1;
    if (!decNumberIsZero(&roundedNumber)) {
        decNumberLogB(&expNum, &roundedNumber, [Number sharedContext]);
        exponent = decNumberToInt32(&expNum, [Number sharedContext]) + 1;
    }
    BOOL useSci = exponent > MAXMANTISSA || exponent <= -significantDigits;

    // Determine the max digits
    DispType dispToUse = disp;
    if (dispToUse != ENG && useSci)
        dispToUse = SCI;
    int maxDigits = 0;
    
    switch(dispToUse) {
        case ALL:
            maxDigits = MAXMANTISSA + 1;
            break;
        case FIX:
            maxDigits = MIN(MAXMANTISSA + 1, significantDigits + ((exponent >= 0) ? exponent : -exponent));
            break;
        case SCI:
        case ENG:
            maxDigits = significantDigits + 1;
            break;
    }

    // Round again to get the final digits.
    [Number sharedContext]->digits = maxDigits;
    decNumberReduce(&roundedNumber, decNum, [Number sharedContext]);
    [Number sharedContext]->digits = DECNUMDIGITS;

    // We need to get exponent again, because it might have changed
    exponent = 1;
    if (!decNumberIsZero(&roundedNumber)) {
        decNumberLogB(&expNum, &roundedNumber, [Number sharedContext]);
        exponent = decNumberToInt32(&expNum, [Number sharedContext]) + 1;
    }
    
    uint8_t mantissa[DECNUMDIGITS];
    decNumberGetBCD(&roundedNumber, mantissa);
    int numDigits = roundedNumber.digits;
    
    // numDigits digits are in mantissa, with the decimal to the left of the first digit
    // exponent is the offset of the decimal point (positive moves decimal to the right)
    // Determine the total number of digits to display, the digits to the left of the decimal
    // and the exponent
    int digitsBeforeDecimal = exponent;
    int decimalDigits = significantDigits;
    int expToDisplay = exponent - 1;
    
    // Truncate decimal digits if it would result in too many digits
    if (!useSci && decimalDigits + digitsBeforeDecimal > MAXMANTISSA + 1)
        decimalDigits = MAXMANTISSA - digitsBeforeDecimal + 1;
    
    if (dispToUse == SCI || dispToUse == ENG) {
        digitsBeforeDecimal = 1;
        
        if (dispToUse == ENG) {
            dispToUse = SCI;
            int expOffset = expToDisplay % 3;
            if (expOffset < 0)
                expOffset += 3;

            if (expOffset != 0) {
                expToDisplay -= expOffset;
                digitsBeforeDecimal += expOffset;
                decimalDigits -= expOffset;
            }
        }
    }
    
    // Adjust to get rid of insignificant digits if we are in ALL
    if (disp == ALL && digitsBeforeDecimal + decimalDigits > numDigits)
        decimalDigits = MAX(0, numDigits - digitsBeforeDecimal);

    // Now display
    NSMutableString* s = [[[NSMutableString alloc] init] autorelease];
    if (decNumberIsNegative(&roundedNumber))
        [s appendString:@"-"];
        
    int mantissaIndex = 0;
    
    // Part before decimal
    if (digitsBeforeDecimal <= 0)
        [s appendString:@"0"];
    else
        for (int i = 0; i < digitsBeforeDecimal; ++i) {
            if (i != 0 && (digitsBeforeDecimal - i) % 3 == 0)
                [s appendString:@","];
                
            [s appendFormat:@"%c", digitFromMantissa(mantissa, &mantissaIndex, numDigits) + '0'];
        }
        
    if (decimalDigits > 0) {
        [s appendString:@"."];
        
        if (dispToUse != SCI) {
            // First display leading 0s
            while (exponent++ < 0) {
                [s appendString:@"0"];
                --decimalDigits;
            }
        }
        
        for (int i = 0; i < decimalDigits; ++i)
            [s appendFormat:@"%c", digitFromMantissa(mantissa, &mantissaIndex, numDigits) + '0'];
    }
    
    if (disp == ENG && expToDisplay >= -12 && expToDisplay <= 12) {
        NSString* e = @"";
        
        switch(expToDisplay) {
            case -12: e = @"p"; break;
            case -9: e = @"n"; break;
            case -6: e = @"µ"; break;
            case -3: e = @"m"; break;
            case 3: e = @"K"; break;
            case 6: e = @"M"; break;
            case 9: e = @"G"; break;
            case 12: e = @"T"; break;
        }
        
        [s appendString:e];
    }
    else if (dispToUse == SCI)
        [s appendFormat:@" E%d", expToDisplay];

    return s;
}

- (NSString*)stringInBase:(BaseType) base format:(DispType) disp precision:(int) significantDigits;
{
    if (base != DEC) {
        disp = ALL;
        significantDigits = MAXMANTISSA;
    }
    
    return string(m_number, base, disp, significantDigits);
    
}

- (double) doubleValue
{
    char s[MAXDECSTRINGSIZE];
    decNumberToString(m_number, s);
    return atof(s);
}

- (void)add:(Number*) rightOperand
{
    if (!rightOperand) {
        g_lastStatus = ST_MISSING_PARAM;
        return;
    }
    
    decNumberAdd(m_number, m_number, [rightOperand decNumber], [Number sharedContext]);
}

- (void)subtract:(Number*) rightOperand
{
    if (!rightOperand) {
        g_lastStatus = ST_MISSING_PARAM;
        return;
    }
    
    decNumberSubtract(m_number, m_number, [rightOperand decNumber], [Number sharedContext]);
}

- (void)multiply:(Number*) rightOperand
{
    if (!rightOperand) {
        g_lastStatus = ST_MISSING_PARAM;
        return;
    }
    
    decNumberMultiply(m_number, m_number, [rightOperand decNumber], [Number sharedContext]);
}

- (void)divide:(Number*) rightOperand
{
    if (!rightOperand) {
        g_lastStatus = ST_MISSING_PARAM;
        return;
    }
    
    decNumberDivide(m_number, m_number, [rightOperand decNumber], [Number sharedContext]);
}

- (void)power:(Number*) rightOperand
{
    if (!rightOperand) {
        g_lastStatus = ST_MISSING_PARAM;
        return;
    }
    
    decNumberPower(m_number, m_number, [rightOperand decNumber], [Number sharedContext]);
}

- (void)abs
{
    decNumberAbs(m_number, m_number, [Number sharedContext]);    
}

- (void)squareRoot
{
    decNumberSquareRoot(m_number, m_number, [Number sharedContext]);    
}

- (void)exp
{
    decNumberExp(m_number, m_number, [Number sharedContext]);    
}

- (void)ln
{
    decNumberLn(m_number, m_number, [Number sharedContext]);    
}

- (void)log
{
    decNumberLog10(m_number, m_number, [Number sharedContext]);    
}

- (int)compare:(Number*) rightOperand
{
    if (!rightOperand) {
        g_lastStatus = ST_MISSING_PARAM;
        return 1;
    }
    
    decNumber tmp;
    decNumberCompare(&tmp, m_number, [rightOperand decNumber], [Number sharedContext]);
    return decNumberIsZero(&tmp) ? 0 : (decNumberIsNegative(&tmp) ? -1 : 1);
}

- (BOOL)zero
{
    return decNumberIsZero(m_number);
}

- (BOOL)negative
{
    return decNumberIsNegative(m_number);
}

- (BOOL)nan
{
    return decNumberIsNaN(m_number);
}

- (BOOL)infinite
{
    return decNumberIsInfinite(m_number);
}

- (void) roundWithSignificantDigits:(int) significantDigits
{
    decNumber scale;
    
    decNumberFromInt32(&scale, significantDigits);
    decNumberScaleB(m_number, m_number, &scale, [Number sharedContext]);
    decNumberToIntegralValue(m_number, m_number, [Number sharedContext]);
    decNumberFromInt32(&scale, -significantDigits);
    decNumberScaleB(m_number, m_number, &scale, [Number sharedContext]);
}

- (void) trunc
{
    decContextSetRounding([Number sharedContext], DEC_ROUND_DOWN);
    decNumberToIntegralValue(m_number, m_number, [Number sharedContext]);
    decContextSetRounding([Number sharedContext], DEC_ROUND_HALF_UP);
}

- (void) frac
{
    decNumber tmp;
    
    decNumberFromInt32(&tmp, 1);
    decNumberRemainder(m_number, m_number, &tmp, [Number sharedContext]);
}

- (void) rand
{
    decNumber a, b, c;
    
    decNumberFromInt32(&a, rand());
    decNumberFromInt32(&b, rand());
    decNumberFromInt32(&c, rand());
    decNumberMultiply(&b, &b, [Number twoToThe32nd], [Number sharedContext]);
    decNumberMultiply(&c, &c, [Number twoToThe32nd], [Number sharedContext]);
    decNumberMultiply(&c, &c, [Number twoToThe32nd], [Number sharedContext]);
    decNumberAdd(m_number, &a, &b, [Number sharedContext]);
    decNumberAdd(m_number, m_number, &c, [Number sharedContext]);
    decNumberDivide(m_number, m_number, [Number twoToThe32nd], [Number sharedContext]);
    decNumberDivide(m_number, m_number, [Number twoToThe32nd], [Number sharedContext]);
    decNumberDivide(m_number, m_number, [Number twoToThe32nd], [Number sharedContext]);
}

- (void) seed
{
    decNumber tmp;
    
    // For now we will just use the integer part for the seed
    decNumberCompare(&tmp, m_number, [Number twoToThe32nd], [Number sharedContext]);
    if (decNumberIsNegative(&tmp)) {
        decNumberToIntegralValue(&tmp, m_number, [Number sharedContext]);
        srand((int32_t) decNumberToUInt32(&tmp, [Number sharedContext]));
    }
    else
        srand(1);
}

@end
