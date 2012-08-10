//
//  RootViewController.m
//  GCDExample
//
//  Created by Jeff Kelley on 2/18/11.
//  Copyright 2011 Jeff Kelley. All rights reserved.
//

#import "RootViewController.h"

#import <objc/runtime.h>


static const void *kRowKey = &kRowKey;


@implementation RootViewController {
    NSString	*imageFolder;
    NSArray 	*imagePathArray;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    imageFolder = [[resourcePath stringByAppendingPathComponent:@"Nature"] copy];
    imagePathArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imageFolder
                                                                      error:NULL];
}

#pragma mark - UITableViewDataSource Protocol Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [imagePathArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:CellIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Get the filename to load.
    NSString *imageFilename = [imagePathArray objectAtIndex:[indexPath row]];
    NSString *imagePath = [imageFolder stringByAppendingPathComponent:imageFilename];
    
    [[cell textLabel] setText:[imageFilename stringByDeletingPathExtension]];
	
	[[cell imageView] setImage:nil];
	
	// Associate the row with the cell
	NSNumber *rowNumber = @([indexPath row]);
	
	objc_setAssociatedObject(cell, kRowKey, rowNumber, OBJC_ASSOCIATION_RETAIN);

	dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

	dispatch_async(backgroundQueue, ^{
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNumber *cellRow = objc_getAssociatedObject(cell, kRowKey);
			
			if ([cellRow isEqualToNumber:rowNumber]) {
				[[cell imageView] setImage:image];
				[cell setNeedsLayout];
			}
		});
	});

	    
	return cell;
}

#pragma mark -

@end
