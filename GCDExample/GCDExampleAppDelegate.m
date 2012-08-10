//
//  GCDExampleAppDelegate.m
//  GCDExample
//
//  Created by Jeff Kelley on 2/18/11.
//  Copyright 2011 Jeff Kelley. All rights reserved.
//

#import "GCDExampleAppDelegate.h"


@implementation GCDExampleAppDelegate

#pragma mark - UIApplicationDelegate Protocol Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[self window] setRootViewController:[self navigationController]];
    [[self window] makeKeyAndVisible];
    
    return YES;
}

#pragma mark -

@end
