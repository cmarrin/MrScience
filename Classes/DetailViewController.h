//
//  DetailViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ViewControllerBase.h"

typedef enum { SHOW, STORE, LOAD, ADD } DetailType;

@interface DetailViewController : TableViewControllerBase<UINavigationControllerDelegate> {
    DetailType m_detailType;
    id m_details;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d detailType:(DetailType) detailType details:(id) details;

@end
