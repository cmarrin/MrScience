//
//  DownloadViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ViewControllerBase.h"

@interface DownloadViewController : TableViewControllerBase<UINavigationControllerDelegate> {
    NSArray* m_programList;
    NSArray* m_directory;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
