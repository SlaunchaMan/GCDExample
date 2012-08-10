//
//  RootViewController.h
//  GCDExample
//
//  Created by Jeff Kelley on 2/18/11.
//  Copyright 2011 Jeff Kelley. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RootViewController : UITableViewController {
    NSArray 	*imageArray;
    NSString	*imageFolder;
	NSCache 	*imageCache;
}

@end
