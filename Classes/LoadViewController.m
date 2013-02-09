//
//  LoadViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "LoadViewController.h"

#import "ListViewController.h"

@implementation LoadViewController

- (BOOL)modal
{
    return YES;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    ListViewController* controller = [[ListViewController alloc]initWithDelegate:d];
    [super initWithRootViewController:controller delegate:d];
    [controller release];
    return self;
}

@end
