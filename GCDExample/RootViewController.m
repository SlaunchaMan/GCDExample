//
//  RootViewController.m
//  GCDExample
//
//  Created by Jeff Kelley on 2/18/11.
//  Copyright 2011 Jeff Kelley. All rights reserved.
//

#import "RootViewController.h"

#import <objc/runtime.h>

#import "UIImage+Resize.h"

#import "JKCallbacksTableViewCell.h"


static char * const kIndexPathAssociationKey = "JK_indexPath";


@interface RootViewController()

- (void)tableViewCellIsPreparingForReuse:(NSNotification *)notification;

@end


@implementation RootViewController

#pragma mark - Object Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self) {
		imageCache = [[NSCache alloc] init];
		[imageCache setName:@"JKImageCache"];
	}
	
	return self;
}

- (void)awakeFromNib
{
	if (!imageCache) {
		imageCache = [[NSCache alloc] init];
		[imageCache setName:@"JKImageCache"];
	}
	
	[super awakeFromNib];
}

- (void)dealloc
{
    [imageFolder release];
    [imageArray release];
	[imageCache release];
    
    [super dealloc];
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    imageFolder = [[resourcePath stringByAppendingPathComponent:@"Pixar-Wallpaper-Pack"] copy];
    imageArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:imageFolder
                                                                      error:NULL] retain];
	
	// Register for our table view cell notification
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tableViewCellIsPreparingForReuse:)
												 name:kJKPrepareForReuseNotification
											   object:nil];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:kJKPrepareForReuseNotification
												  object:nil];
	
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
	[imageCache removeAllObjects];
	
	[super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource Protocol Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [imageArray count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    JKCallbacksTableViewCell *cell = (JKCallbacksTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[JKCallbacksTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
												reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Get the filename to load.
    NSString *imageFilename = [imageArray objectAtIndex:[indexPath row]];
    NSString *imagePath = [imageFolder stringByAppendingPathComponent:imageFilename];
    
    [[cell textLabel] setText:imageFilename];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	// If we already have an image cached for the cell, use that. Otherwise we need to go into the 
	// background and generate it.
	UIImage *image = [imageCache objectForKey:imageFilename];
	if (image) {
		[[cell imageView] setImage:image];
	} else {    
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
		
		// Get the height of the cell to pass to the block.
		CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
		
		// Now, we can’t cancel a block once it begins, so we’ll use associated objects and compare
		// index paths to see if we should continue once we have a resized image.
		objc_setAssociatedObject(cell,
								 kIndexPathAssociationKey,
								 indexPath,
								 OBJC_ASSOCIATION_RETAIN);
		
		dispatch_async(queue, ^{
			UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
			
			UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
																bounds:CGSizeMake(cellHeight, cellHeight)
												  interpolationQuality:kCGInterpolationHigh];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				NSIndexPath *cellIndexPath =
				(NSIndexPath *)objc_getAssociatedObject(cell, kIndexPathAssociationKey);
				
				if ([indexPath isEqual:cellIndexPath]) {
					[[cell imageView] setImage:resizedImage];
				}
				
				[imageCache setObject:resizedImage forKey:imageFilename];
			});
		});
	}
    
    return cell;
}

#pragma mark -

- (void)tableViewCellIsPreparingForReuse:(NSNotification *)notification
{
	if ([[notification object] isKindOfClass:[JKCallbacksTableViewCell class]]) {
		JKCallbacksTableViewCell *cell = (JKCallbacksTableViewCell *)[notification object];
		
		objc_setAssociatedObject(cell,
								 kIndexPathAssociationKey,
								 nil,
								 OBJC_ASSOCIATION_RETAIN);
		
		[[cell imageView] setImage:nil];
	}
}

@end
