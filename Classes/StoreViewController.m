//
//  StoreViewController.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "StoreViewController.h"

#import "DetailViewController.h"

@implementation StoreViewController

- (BOOL)modal
{
    return YES;
}

- (id)initWithDelegate:(id<ControllerProtocol>) d
{
    DetailViewController* controller = [[DetailViewController alloc]initWithDelegate:d detailType:STORE details:d.calculator];
    [super initWithRootViewController:controller delegate:d];
    [controller release];
    return self;
}

@end
