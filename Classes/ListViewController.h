//
//  ListViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ViewControllerBase.h"

@interface ListViewController : TableViewControllerBase<UINavigationControllerDelegate> {
    NSArray* m_list;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
