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


@interface RootViewController() {
	NSMutableDictionary *cache;
	dispatch_queue_t cacheQueue;
}

- (NSMutableDictionary *)cache;
- (dispatch_queue_t)cacheQueue;
- (id)objectInCacheForKey:(id)key;
- (void)setObject:(id)object inCacheForKey:(id)key;

@end


@implementation RootViewController {
    NSString	*imageFolder;
    NSArray 	*imagePathArray;
}

#pragma mark - Cache Access

- (NSMutableDictionary *)cache
{
	if (cache == nil) {
		cache = [[NSMutableDictionary alloc] init];
	}
	
	return cache;
}

- (dispatch_queue_t)cacheQueue
{
	if (cacheQueue == NULL) {
		cacheQueue = dispatch_queue_create("com.slaunchaman.cachequeue", DISPATCH_QUEUE_CONCURRENT);
	}
	
	return cacheQueue;
}

- (id)objectInCacheForKey:(id)key
{
	__block id object = nil;
	
	dispatch_sync([self cacheQueue], ^{
		object = [[self cache] objectForKey:key];
	});
	
	return object;
}

- (void)setObject:(id)object inCacheForKey:(id)key
{
	dispatch_barrier_async([self cacheQueue], ^{
		[[self cache] setObject:object forKey:key];
	});
}

#pragma mark - Object Lifecycle

- (void)dealloc
{
	if (cacheQueue != NULL) {
		dispatch_release(cacheQueue);
	}
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

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	dispatch_barrier_async([self cacheQueue], ^{
		[[self cache] removeAllObjects];
	});
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
	
	// Do we have a cached image?
	UIImage *cachedImage = [self objectInCacheForKey:rowNumber];
	
	if (cachedImage != nil) {
		[[cell imageView] setImage:cachedImage];
	}
	else {
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
			
			[self setObject:image inCacheForKey:rowNumber];
		});
	}
	    
	return cell;
}

#pragma mark -

@end
