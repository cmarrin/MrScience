//
//  RegButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "RegButtonViewController.h"

@implementation RegButtonViewController

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    NSString* nib;
    
    if (d.calculator.inputMode == IM_REG)
        nib = @"RegButtonSubrView";
    else {
        switch(d.currentOp) {
            case OP_CALL:
            case OP_INPUT:
                nib = @"RegButtonCallView"; break;
            case OP_DEF_SUBR:
                nib = @"RegButtonSubrView"; break;
            default:
                nib = @"RegButtonView"; break;
        }
    }
    
    return [super initWithNibName:nib delegate:d];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)handleButton:(UIButton*) button
{
    switch (button.tag) {
        case buttonRegDivide:
        case buttonRegMultiply:
        case buttonRegSubtract:
        case buttonRegAdd:
            m_regFunctionButton.selected = NO;
            m_regFunctionButton = button;
            m_regFunctionButton.selected = YES;

            switch(m_regFunctionButton.tag) {
                case buttonRegDivide: m_delegate.currentOp = (m_delegate.currentOp == OP_STO) ? OP_STO_DIV : OP_RCL_DIV; break;
                case buttonRegMultiply: m_delegate.currentOp = (m_delegate.currentOp == OP_STO) ? OP_STO_MUL : OP_RCL_MUL; break;
                case buttonRegSubtract: m_delegate.currentOp = (m_delegate.currentOp == OP_STO) ? OP_STO_SUB : OP_RCL_SUB; break;
                case buttonRegAdd: m_delegate.currentOp = (m_delegate.currentOp == OP_STO) ? OP_STO_ADD : OP_RCL_ADD; break;
            }
            return;
        case buttonRegCancel:
            m_delegate.currentOp = OP_NONE;
            break;
        default:
            break;
    }
    
    m_regFunctionButton.selected = NO;
    m_regFunctionButton = nil;
    int reg = button.tag - buttonRegBase;
    
    if (m_delegate.calculator.inputMode == IM_REG) {
        if (button.tag == buttonRegCancel)
            [m_delegate.calculator quit];
        else {
            // Push the reg into the X reg
            [m_delegate.calculator enterIfNeeded];
            [m_delegate.calculator setXFromNumber:[Number numberWithDouble:reg]];
            [m_delegate.calculator run];
        }
    }
    
    if (m_delegate.currentOp == OP_DEF_SUBR)
        [m_delegate.calculator nameCurrentSubroutine:reg];
    else if (m_delegate.currentOp == OP_INPUT)
        [m_delegate.calculator op:OP_INPUT withParams:[NSArray arrayWithObjects:[NSNumber numberWithInt:reg], m_delegate.currentString, nil]];
    else if (m_delegate.currentOp != OP_NONE)
        [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:reg]]];
    
    if (m_delegate.currentOp == OP_CALL || m_delegate.currentOp == OP_DEF_SUBR || m_delegate.currentOp == OP_INPUT)
        [m_delegate showView:@"ProgrammingView"];
    else
        [m_delegate showView:@"FirstButtonView"];
        
    m_delegate.currentOp = OP_NONE;
    m_delegate.currentString = nil;
}

@end
