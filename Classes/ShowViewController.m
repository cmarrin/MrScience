//
//  ShowViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "ShowViewController.h"

#import "DetailViewController.h"

@implementation ShowViewController

- (BOOL)modal
{
    return YES;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    DetailViewController* controller = [[DetailViewController alloc]initWithDelegate:d detailType:SHOW details:d.calculator];
    [super initWithRootViewController:controller delegate:d];
    [controller release];
    return self;
}

@end
