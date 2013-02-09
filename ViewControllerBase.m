//
//  ViewControllerBase.m
//  MrScience
//
//  Created by Chris Marrin on 3/16/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ViewControllerBase.h"

@implementation ViewControllerBase

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    return nil;
}

- (id)initWithNibName:(NSString*) nib delegate:(id<ControllerProtocol>) d
{
    m_delegate = d;
    [super initWithNibName:nib bundle:nil];
    return self;
}

- (BOOL)viewChanged
{
    return NO;
}

- (BOOL)modal
{
    return NO;
}

- (UIModalTransitionStyle)modalTransitionStyle
{
    return UIModalTransitionStyleCrossDissolve;
}

@end

@implementation TableViewControllerBase

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<ControllerProtocol>) d
{
    m_delegate = d;
    [super initWithStyle:style];
    return self;
}

@end

@implementation NavigationControllerBase

- (id)initWithRootViewController:(UIViewController *)rootViewController delegate:(id<ControllerProtocol>) d
{
    m_delegate = d;
    [super initWithRootViewController:rootViewController];
    return self;
}

@end
