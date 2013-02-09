//
//  SecondButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "SecondButtonViewController.h"

@implementation SecondButtonViewController

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    return [super initWithNibName:(d.calculator.base == DEC) ? @"SecondButtonView" : @"HexBinOctSecondButtonView" delegate:d];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)handleButton:(UIButton*) button
{
    switch (button.tag) {
        case buttonDispALL:
            [m_delegate.calculator op:OP_DISP_ALL withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:MAXMANTISSA]]];
            [m_delegate showView:@"FirstButtonView"];
            break;
        case buttonDispFIX:
            m_delegate.currentOp = OP_DISP_FIX;
            [m_delegate showView:@"DispButtonView"];
            break;
        case buttonDispSCI:
            m_delegate.currentOp = OP_DISP_SCI;
            [m_delegate showView:@"DispButtonView"];
            break;
        case buttonDispENG:
            m_delegate.currentOp = OP_DISP_ENG;
            [m_delegate showView:@"DispButtonView"];
            break;

        case buttonModeDEG: [m_delegate.calculator op:OP_MODE_DEG]; break;
        case buttonModeRAD: [m_delegate.calculator op:OP_MODE_RAD]; break;
        case buttonModeGRAD: [m_delegate.calculator op:OP_MODE_GRAD]; break;
        default:
            [super handleButton:button];
            return;
    }
}

@end
