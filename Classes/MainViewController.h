//
//  MainViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "Calculator.h"
#import "ViewControllerBase.h"
#import "FlipsideViewController.h"

@class ViewControllerBase;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, ControllerProtocol> {
    IBOutlet UILabel* m_xRegisterDisplay;
    IBOutlet UILabel* m_yRegisterDisplay;
    IBOutlet UILabel* m_zRegisterDisplay;
    IBOutlet UILabel* m_tRegisterDisplay;
    IBOutlet UILabel* m_lastXRegisterDisplay;
    IBOutlet UILabel* m_infoDisplay;
    IBOutlet UILabel* m_modeDisplay;
    IBOutlet UILabel* m_dispDisplay;
    
    IBOutlet UIView* m_placeholderView;
    
    ViewControllerBase* m_currentViewController;
    
    Calculator* m_calculator;
    OperationType m_currentOp;

    NSString* m_currentPrompt;
    NSString* m_currentString;
    
    BOOL m_hyperbolic;
}

- (IBAction)showInfo;

- (void)showInfoFile:(NSString*) filename;

- (void)cleanup;

@end
