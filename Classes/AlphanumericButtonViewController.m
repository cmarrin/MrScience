//
//  AlphanumericButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "AlphanumericButtonViewController.h"

#import "MainViewController.h"

#define buttonAlphanumericSuper2    97  // a - superscript 2
#define buttonAlphanumericSuper3    98  // b - superscript 3
#define buttonAlphanumericRArrow    101 // e - right arrow
#define buttonAlphanumericLE        102 // f - less than or equal to
#define buttonAlphanumericGE        103 // g - greater than or equal to
#define buttonAlphanumericPi        104 // h - pi
#define buttonAlphanumericDelta     105 // i - delta
#define buttonAlphanumericTheta     106 // j - theta
#define buttonAlphanumericSigma     107 // k - sigma
#define buttonAlphanumericInfinity  108 // l - infinity
#define buttonAlphanumericDivide    109 // m - division
#define buttonAlphanumericMultiply  110 // n - multiplication
#define buttonAlphanumericSummation 111 // o - summation
#define buttonAlphanumericDegrees   112 // p - degrees

#define buttonAlphanumericCancel    0
#define buttonAlphanumericOK        1
#define buttonAlphanumericShift     2
#define buttonAlphanumericUnshift   3
#define buttonAlphanumericBS        8

// Keep these in sync with the special characters above
#define FirstSpecialCharacter       buttonAlphanumericSuper2
#define LastSpecialCharacter        buttonAlphanumericDegrees

@implementation AlphanumericButtonViewController

static NSDictionary* translationMap()
{
    static NSDictionary* map;
    if (!map)
        map = [[NSDictionary dictionaryWithObjectsAndKeys:
                     @"²", [NSNumber numberWithInt:buttonAlphanumericSuper2],
                     @"³", [NSNumber numberWithInt:buttonAlphanumericSuper3],
                     @"➜", [NSNumber numberWithInt:buttonAlphanumericRArrow],
                     @"≤", [NSNumber numberWithInt:buttonAlphanumericLE],
                     @"≥", [NSNumber numberWithInt:buttonAlphanumericGE],
                     @"π", [NSNumber numberWithInt:buttonAlphanumericPi],
                     @"Δ", [NSNumber numberWithInt:buttonAlphanumericDelta],
                     @"θ", [NSNumber numberWithInt:buttonAlphanumericTheta],
                     @"σ", [NSNumber numberWithInt:buttonAlphanumericSigma],
                     @"∞", [NSNumber numberWithInt:buttonAlphanumericInfinity],
                     @"÷", [NSNumber numberWithInt:buttonAlphanumericDivide],
                     @"×", [NSNumber numberWithInt:buttonAlphanumericMultiply],
                     @"∑", [NSNumber numberWithInt:buttonAlphanumericSummation],
                     @"°", [NSNumber numberWithInt:buttonAlphanumericDegrees],
                     nil] retain];
    return map;
}
    
- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    return [super initWithNibName:m_alphanumericShift ? @"AlphanumericShiftButtonView" : @"AlphanumericButtonView" delegate:d];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!m_delegate.currentString || [m_delegate.currentString length] == 0)
        m_delegate.currentString = @"_";
}

- (void)handleButton:(UIButton*) button
{
    if (button.tag < buttonAlphanumericOffset) {
        [super handleButton:button];
        return;
    }
        
    NSString* view = @"AlphanumericButtonView";

    int tag = button.tag - buttonAlphanumericOffset;
    
    if (tag > 255) {
        [super handleButton:button];    
        return;
    }
        
    NSUInteger maxChars;
    switch (m_delegate.currentOp) {
        case OP_INPUT: maxChars = 24; break;
        case OP_DEF_FUNC: maxChars = 8; break;
        default: return;
    }

    if (tag >= 32) {
        if ([m_delegate.currentString length] <= maxChars) {
            NSString* c = (tag >= FirstSpecialCharacter && tag <= LastSpecialCharacter) ?
                [translationMap() objectForKey:[NSNumber numberWithInt:tag]] : [NSString stringWithFormat:@"%c", tag];
                    
            NSString* newString = [m_delegate.currentString substringToIndex:[m_delegate.currentString length] - 1];
            m_delegate.currentString = [newString stringByAppendingFormat:@"%@_", c];
        }
    }
    else {
        switch(tag) {
            case buttonAlphanumericOK:
                if (m_delegate.currentOp == OP_DEF_FUNC)
                    [m_delegate.calculator nameCurrentFunction:
                        [m_delegate.currentString substringToIndex:[m_delegate.currentString length] - 1]];
                else if (m_delegate.currentOp == OP_INPUT) {
                    // Next ask for a register to store value in
                    [m_delegate showView:@"RegButtonView"];
                    m_delegate.currentPrompt = @"Enter reg to store input";
                    m_delegate.currentString = [m_delegate.currentString substringToIndex:[m_delegate.currentString length] - 1];
                    return;
                }
                // Fall through
            case buttonAlphanumericCancel:
                //m_delegate.alphanumericShift = NO;
                m_delegate.currentString = nil;
                m_delegate.currentOp = OP_NONE;
                view = @"ProgrammingView";
                break;
            case buttonAlphanumericShift:
                //delegate.alphanumericShift = YES;
                break;
            case buttonAlphanumericUnshift:
                //delegate.alphanumericShift = NO;
                break;
            case buttonAlphanumericBS:
                if ([m_delegate.currentString length] > 1) {
                    // Deal with underscore
                    NSString* newString = [m_delegate.currentString substringToIndex:[m_delegate.currentString length] - 2];
                    m_delegate.currentString = [newString stringByAppendingString:@"_"];
                }
                break;
            default:
                [super handleButton:button];
                return;
        }
    }
    
    [m_delegate showView:view];
}

@end
