//
//  FunctionButtonViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ButtonViewController.h"

@interface FunctionButtonViewController : ButtonViewController {
    IBOutlet UIButton* m_programTitle;
    IBOutlet UILabel* m_userLabel1;
    IBOutlet UILabel* m_userLabel2;
    IBOutlet UILabel* m_userLabel3;
    IBOutlet UILabel* m_userLabel4;
    IBOutlet UILabel* m_userLabel5;
    IBOutlet UILabel* m_userLabel6;
    IBOutlet UILabel* m_userLabel7;
    IBOutlet UILabel* m_userLabel8;
    IBOutlet UILabel* m_userLabel9;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
