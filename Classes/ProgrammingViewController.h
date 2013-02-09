//
//  ProgrammingViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ButtonViewController.h"

@interface ProgrammingViewController : ButtonViewController {
    IBOutlet UIButton* m_addButton;
    IBOutlet UITableView* m_tableView;
    IBOutlet UIView* m_headerView;
    IBOutlet UILabel* m_xRegisterDisplay;
    IBOutlet UILabel* m_infoDisplay;
    
    CGFloat m_tableWidth, m_tableRowHeight, m_tableHeaderHeight;
    
    NSUInteger m_selectedFunc, m_selectedInst;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

- (void)selectCell:(UITableViewCell*) cell;
- (void)keepSelectedLineVisible;

@end

@interface ProgramTableView : UITableView {
}

@end
