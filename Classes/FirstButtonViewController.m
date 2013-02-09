//
//  FirstButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "FirstButtonViewController.h"

#import "MainViewController.h"

@interface FirstButtonViewController (Private)

- (NSString*)stringFromNumberEntry:(BOOL) forConversion;

@end;

@implementation FirstButtonViewController

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    NSString* nib;
    switch (d.calculator.base) {
        case DEC: nib = @"FirstButtonView"; break;
        case HEX: nib = @"HexButtonView"; break;
        case BIN: nib = @"BinButtonView"; break;
        case OCT: nib = @"OctButtonView"; break;
    }
    
    return [super initWithNibName:nib delegate:d];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup entry variables
    m_mantissa = [[NSMutableString alloc] init];
    m_exponent = [[NSMutableString alloc] init];
}

typedef enum { DECIMAL, FRACTION, DISABLED_DECIMAL, DISABLED_FRACTION } DecimalButtonState;

- (void)setDecimalButtonState:(DecimalButtonState) state
{
    NSString* string = (state == DECIMAL || state == DISABLED_DECIMAL) ? @"." : @"/";
    UIColor* color = (state == DECIMAL || state == FRACTION) ? [UIColor whiteColor] : [UIColor grayColor];
    
    [m_decimalButton setTitle:string forState:UIControlStateNormal];
    [m_decimalButton setTitle:string forState:UIControlStateHighlighted];
    [m_decimalButton setTitle:string forState:UIControlStateDisabled];
    
    [m_decimalButton setTitleColor:color forState:UIControlStateNormal];
    [m_decimalButton setTitleColor:color forState:UIControlStateHighlighted];
    [m_decimalButton setTitleColor:color forState:UIControlStateDisabled];
    
    m_decimalButton.enabled = state == DECIMAL || state == FRACTION;
}

static void removeLastChar(NSMutableString* s)
{
    [s setString:[s substringToIndex:[s length] - 1]];
}

- (BOOL)isMantissaZero
{
    return [[m_mantissa stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0."]] length] == 0;
}

static NSString* insertSeparatorsForDec(NSString* s)
{
    NSString* mantissa = @"";
    
    if ([s length]) {
        NSRange range = [s rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@". "]];
        unsigned int dp = (range.location == NSNotFound) ? [s length] : range.location;
        
        for (int i = dp; i > 0; i -= 3) {
            range.location = (i < 3) ? 0 : i - 3;
            range.length = (i < 3) ? i : 3;
            if ([mantissa length])
                mantissa = [NSString stringWithFormat:@"%@,%@", [s substringWithRange:range], mantissa];
            else
                mantissa = [s substringWithRange:range];
        }
        
        // append part past the dp
        if (dp != [s length])
            mantissa = [NSString stringWithFormat:@"%@%@", mantissa, [s substringFromIndex:dp]];
    }

    return mantissa;    
}

static NSString* insertSeparatorsForHex(NSString* s)
{
    NSString* mantissa = @"";
    
    if ([s length]) {
        for (int i = [s length]; i > 0; i -= 4) {
            NSRange range;
            range.location = (i < 4) ? 0 : i - 4;
            range.length = (i < 4) ? i : 4;
            if ([mantissa length])
                mantissa = [NSString stringWithFormat:@"%@ %@", [s substringWithRange:range], mantissa];
            else
                mantissa = [s substringWithRange:range];
        }
    }
    
    return mantissa;
}

- (NSString*)stringFromNumberEntry:(BOOL) forConversion
{
    if (m_delegate.calculator.base != DEC) {
        // For hex and bin, display digits with a space between every 4th digit
        // For oct, just display digits with no spaces
        
        // Insert separators into mantissa
        NSString* mantissa = m_mantissa;
        
        if (!forConversion && (m_delegate.calculator.base == HEX || m_delegate.calculator.base == BIN))
            mantissa = insertSeparatorsForHex(m_mantissa);
        
        // If m_mantissa size is 0, display '0' in place of m_mantissa.
        mantissa = [NSString stringWithFormat:@"%@%@%@", m_negativeMantissa ? @"-" : @"", [mantissa length] ? mantissa : @"0", forConversion ? @"" : @"_"];
        return mantissa;
    }
    
    // Display format for decimal is:
    //
    //  [m_negativeMantissa] m_mantissa [' E' [m_negativeExponent] m_exponent]
    //                                  |--- only if m_hasExponent is YES ---|
    //
    // For hex and bin, display digits with a space between every 4th digit
    //
    // For oct, just display digits with no spaces
    NSString* mantissa = m_mantissa;
    
    // Get rid of decimal point if we have a fraction
    if (m_hasFraction) {
        if (forConversion) {
            // Convert the fraction notation to decimal
            NSArray* parts = [mantissa componentsSeparatedByString:@"."];
            if ([parts count] == 2) {
                NSArray* fraction = [[parts objectAtIndex:1] componentsSeparatedByString:@"/"];
                double num = 0;
                if ([fraction count] == 2 && [[fraction objectAtIndex:1] length] > 0) {
                    double denom = [[fraction objectAtIndex:1] doubleValue];
                    if (denom > 0)
                        num = [[fraction objectAtIndex:0] doubleValue] / denom;
                }
                
                num += [[parts objectAtIndex:0] doubleValue];
                mantissa = [NSString stringWithFormat:@"%f", num];
            }
        }
        else
            mantissa = [mantissa stringByReplacingOccurrencesOfString:@"." withString:@" "];
    }
    
    // Insert separators into mantissa
    if (!forConversion)
        mantissa = insertSeparatorsForDec(mantissa);
        
    // If m_mantissa size is 0, display '0' in place of m_mantissa.
    mantissa = [NSString stringWithFormat:@"%@%@", m_negativeMantissa ? @"-" : @"", [mantissa length] ? mantissa : @"0"];
    NSString* exponent = @"";
    if (m_hasExponent)
        exponent = [NSString stringWithFormat:@"%@%@%@", 
                        forConversion ? @"E" : @" E",
                        m_negativeExponent ? @"-" : @"",
                        m_exponent];

    return [NSString stringWithFormat:@"%@%@%@", mantissa, exponent, forConversion ? @"" : @"_"];
}

- (void)commitNumber
{
    if (m_enteringNumber) {
        [m_delegate.calculator setXFromString:[self stringFromNumberEntry:YES]];
        m_enteringNumber = NO;
        m_negativeMantissa = NO;
        m_negativeExponent = NO;
        m_hasExponent = NO;
        m_hasDecimal = NO;
        m_hasFraction = NO;
        [self setDecimalButtonState:DECIMAL];

        [m_mantissa setString:@""];
        [m_exponent setString:@""];
        m_delegate.currentString = nil;
    }
}

- (BOOL)handleNumericButton:(int)tag
{
    NSString* numberToAdd = nil;
    
    if (m_delegate.calculator.inputMode == IM_DIGIT) {
        assert(!m_enteringNumber);
        
        switch(tag) {
            case button0: numberToAdd = @"0"; break;
            case button1: numberToAdd = @"1"; break;
            case button2: numberToAdd = @"2"; break;
            case button3: numberToAdd = @"3"; break;
            case button4: numberToAdd = @"4"; break;
            case button5: numberToAdd = @"5"; break;
            case button6: numberToAdd = @"6"; break;
            case button7: numberToAdd = @"7"; break;
            case button8: numberToAdd = @"8"; break;
            case button9: numberToAdd = @"9"; break;
            case buttonHexA: numberToAdd = @"A"; break;
            case buttonHexB: numberToAdd = @"B"; break;
            case buttonHexC: numberToAdd = @"C"; break;
            case buttonHexD: numberToAdd = @"D"; break;
            case buttonHexE: numberToAdd = @"E"; break;
            case buttonHexF: numberToAdd = @"F"; break;
            default:return NO;
        }

        m_enteringNumber = YES;
        [m_mantissa appendString:numberToAdd];
        [self commitNumber];
        [m_delegate.calculator run];
        return YES;
    }

    switch(tag)
    {
        case buttonChangeSign:
            if (m_hasExponent)
                m_negativeExponent = !m_negativeExponent;
            else
                m_negativeMantissa = !m_negativeMantissa;
            break;
        case buttonExponent:
            if (m_hasExponent)
                break;
            
            if (![m_mantissa length])
                [m_mantissa appendString:@"1"];
            m_hasExponent = YES;
            break;
        case buttonBackspace:
            if (m_hasExponent) {
                if ([m_exponent length])
                    removeLastChar(m_exponent);
                else if (m_negativeExponent)
                    m_negativeExponent = NO;
                else
                    m_hasExponent = NO;
            } else if ([m_mantissa length]) {
                if ([m_mantissa characterAtIndex:[m_mantissa length] - 1] == '/') {
                    [self setDecimalButtonState:FRACTION];
                    m_hasFraction = NO;
                }
                else if ([m_mantissa characterAtIndex:[m_mantissa length] - 1] == '.') {
                    [self setDecimalButtonState:DECIMAL];
                    m_hasDecimal = NO;
                }
                removeLastChar(m_mantissa);
                
                // If the char removed was the first digit past the decimal, we can't do fractions
                if (!m_hasFraction && m_hasDecimal && [m_mantissa characterAtIndex:[m_mantissa length] - 1] == '.')
                    [self setDecimalButtonState:DISABLED_DECIMAL];
            } else if (m_negativeMantissa)
                m_negativeMantissa = NO;
        
            break;
        case buttonDecimal:
            if (m_hasDecimal) {
                // Handle fraction
                m_hasFraction = true;
                [self setDecimalButtonState:DISABLED_FRACTION];
                [m_mantissa appendString:@"/"];
                break;
            }
                
            m_hasDecimal = YES;
            [self setDecimalButtonState:DISABLED_DECIMAL];
            
            if (![m_mantissa length])
                [m_mantissa appendString:@"0"];
            [m_mantissa appendString:@"."];
            break;
        case button0:
            if (!m_hasDecimal && [self isMantissaZero])
                break;
            numberToAdd = @"0"; break;
        case button1: numberToAdd = @"1"; break;
        case button2: numberToAdd = @"2"; break;
        case button3: numberToAdd = @"3"; break;
        case button4: numberToAdd = @"4"; break;
        case button5: numberToAdd = @"5"; break;
        case button6: numberToAdd = @"6"; break;
        case button7: numberToAdd = @"7"; break;
        case button8: numberToAdd = @"8"; break;
        case button9: numberToAdd = @"9"; break;
        case buttonHexA: numberToAdd = @"A"; break;
        case buttonHexB: numberToAdd = @"B"; break;
        case buttonHexC: numberToAdd = @"C"; break;
        case buttonHexD: numberToAdd = @"D"; break;
        case buttonHexE: numberToAdd = @"E"; break;
        case buttonHexF: numberToAdd = @"F"; break;
        default:
            return NO;
    }
    
    if (numberToAdd) {
        if (m_hasExponent) {
            int len = MAXMANTISSA;
            if (m_hasDecimal)
                len++;
            if ([m_exponent length] < MAXEXPONENT)
            [m_exponent appendString:numberToAdd];
        } else {
            // If this is the first digit past the decimal point, we can now make it a fraction
            if (!m_hasFraction && m_hasDecimal && [m_mantissa characterAtIndex:[m_mantissa length] - 1] == '.')
                [self setDecimalButtonState:FRACTION];
            
            if ([m_mantissa length] < MAXMANTISSA + (unsigned int) m_hasDecimal)
                [m_mantissa appendString:numberToAdd];
                
            
        }
    }

    if (!m_enteringNumber) {
        if (m_delegate.calculator.inputMode == IM_NONE || m_delegate.calculator.inputMode == IM_DIGIT)
            [m_delegate.calculator enterIfNeeded];
        m_enteringNumber = YES;
    }
    
    m_delegate.currentString = [self stringFromNumberEntry:NO];
    return YES;
}

- (void)handleButton:(UIButton*) button
{
    if ([self handleNumericButton:button.tag])
        return;
    
    [self commitNumber];
    [super handleButton:button];
}

@end
