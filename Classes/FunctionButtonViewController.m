//
//  FunctionButtonViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "FunctionButtonViewController.h"

#import "MainViewController.h"

@interface FunctionButtonViewController (Private)

- (void)updateDisplay;

@end

@implementation FunctionButtonViewController

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    return [super initWithNibName:@"FunctionButtonView" delegate:d];
}

- (void)dealloc
{
    [m_delegate.calculator removeAllUpdateNotificationsForTarget:self];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Update all function key names
    m_userLabel1.text = [m_delegate.calculator functionNameForKey:1];
    m_userLabel2.text = [m_delegate.calculator functionNameForKey:2];
    m_userLabel3.text = [m_delegate.calculator functionNameForKey:3];
    m_userLabel4.text = [m_delegate.calculator functionNameForKey:4];
    m_userLabel5.text = [m_delegate.calculator functionNameForKey:5];
    m_userLabel6.text = [m_delegate.calculator functionNameForKey:6];
    m_userLabel7.text = [m_delegate.calculator functionNameForKey:7];
    m_userLabel8.text = [m_delegate.calculator functionNameForKey:8];
    m_userLabel9.text = [m_delegate.calculator functionNameForKey:9];

    [m_delegate.calculator addUpdateNotificationWithTarget:self selector:@selector(updateDisplay)];
    [self updateDisplay];
}

- (void)updateDisplay
{
    [m_programTitle setTitle:m_delegate.calculator.title forState:UIControlStateNormal];
    m_programTitle.enabled = [m_delegate.calculator.title length];
}

- (void)handleButton:(UIButton*) button
{
    NSString* view = @"FirstButtonView";
    
    switch(button.tag) {
        case buttonFUNShowInfo:
            [m_delegate showView:@"ShowView"];
            return;
        case buttonFUNName:
            [m_delegate showView:@"StoreView"];
            return;
        case buttonFUNLoad:
            // If the current program is not named, give the choice to name it
            if (![m_delegate.calculator.title length]) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Current program is not named" 
                                                          message:@"Overwrite or name it?" delegate:self 
                                                          cancelButtonTitle:@"Cancel" otherButtonTitles:@"Overwrite", @"Name it", nil];
                [alert show];	
                [alert release];
                return;
            }
            
            [m_delegate showView:@"LoadView"];
            return;
        default:
            [super handleButton:button];
            return;
    }
    
    [m_delegate showView:view];
}

// UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // 0 - cancel, 1 - overwrite, 2 - name it
    if (buttonIndex == 1)
        [m_delegate showView:@"LoadView"];
    else if (buttonIndex == 2)
        [m_delegate showView:@"StoreView"];
}

@end
