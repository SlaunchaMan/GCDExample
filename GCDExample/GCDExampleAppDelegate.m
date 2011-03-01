//
//  GCDExampleAppDelegate.m
//  GCDExample
//
//  Created by Jeff Kelley on 2/18/11.
//  Copyright 2011 Jeff Kelley. All rights reserved.
//

#import "GCDExampleAppDelegate.h"


@implementation GCDExampleAppDelegate

@synthesize navigationController;
@synthesize window;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[self window] setRootViewController:[self navigationController]];
    [[self window] makeKeyAndVisible];
    
    return YES;
}

- (void)dealloc
{
    [window release];
    [navigationController release];

    [super dealloc];
}

@end
