//
//  RegButtonViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ButtonViewController.h"

#import "MainViewController.h"

@interface RegButtonViewController : ButtonViewController {
    UIButton* m_regFunctionButton;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
