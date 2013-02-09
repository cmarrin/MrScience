//
//  ViewControllerBase.h
//  MrScience
//
//  Created by Chris Marrin on 3/16/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Calculator.h"

@protocol ControllerProtocol

@property(readonly) Calculator* calculator;
@property(retain) NSString* currentPrompt;
@property(retain) NSString* currentString;
@property(assign) OperationType currentOp;
@property(assign) BOOL hyperbolic;

- (void)showView:(NSString*) view;

@end

@interface ViewControllerBase : UIViewController {
	id<ControllerProtocol> m_delegate;
}

- (id)initWithNibName:(NSString*) nib delegate:(id<ControllerProtocol>) d;
- (id)initWithDelegate:(id<ControllerProtocol>) d;

- (BOOL)viewChanged;
- (BOOL)modal;
- (UIModalTransitionStyle)modalTransitionStyle;

@end

@interface TableViewControllerBase : UITableViewController {
	id<ControllerProtocol>  m_delegate;
}

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<ControllerProtocol>) d;

@end

@interface NavigationControllerBase : UINavigationController {
	id<ControllerProtocol>  m_delegate;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController delegate:(id<ControllerProtocol>) d;

@end


