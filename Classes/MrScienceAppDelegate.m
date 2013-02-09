//
//  MrScienceAppDelegate.m
//  MrScience
//
//  Created by Chris Marrin on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "MrScienceAppDelegate.h"
#import "MainViewController.h"

@implementation MrScienceAppDelegate


@synthesize window;
@synthesize mainViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.mainViewController cleanup];
}

- (void)dealloc
{
    self.window = nil;
    [super dealloc];
}

@end
