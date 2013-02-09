//
//  DispButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "DispButtonViewController.h"

@implementation DispButtonViewController

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    return [super initWithNibName:@"DispButtonView" delegate:d];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)handleButton:(UIButton*) button
{
    switch (button.tag) {
        case buttonPrecisionCancel: break;
        case buttonPrecision0: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]]; break;
        case buttonPrecision1: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:1]]]; break;
        case buttonPrecision2: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:2]]]; break;
        case buttonPrecision3: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:3]]]; break;
        case buttonPrecision4: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:4]]]; break;
        case buttonPrecision5: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:5]]]; break;
        case buttonPrecision6: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:6]]]; break;
        case buttonPrecision7: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:7]]]; break;
        case buttonPrecision8: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:8]]]; break;
        case buttonPrecision9: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:9]]]; break;
        case buttonPrecision10: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:10]]]; break;
        case buttonPrecision11: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:11]]]; break;
        case buttonPrecision12: [m_delegate.calculator op:m_delegate.currentOp withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:12]]]; break;
        default:
            [super handleButton:button];
            return;
    }

    [m_delegate showView:@"FirstButtonView"];
}

@end
