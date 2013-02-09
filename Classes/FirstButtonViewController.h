//
//  FirstButtonViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ButtonViewController.h"

@interface FirstButtonViewController : ButtonViewController {
    IBOutlet UIButton* m_decimalButton;

    // Data entry values
    BOOL m_negativeMantissa, m_negativeExponent;
    BOOL m_hasExponent;
    BOOL m_hasDecimal;
    BOOL m_hasFraction;
    NSMutableString* m_mantissa;
    NSMutableString* m_exponent;
    BOOL m_enteringNumber;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
