//
//  AlphanumericButtonViewController.h
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ButtonViewController.h"

@interface AlphanumericButtonViewController : ButtonViewController {
    BOOL m_alphanumericShift;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d;

@end
