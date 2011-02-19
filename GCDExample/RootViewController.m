//
//  RootViewController.m
//  GCDExample
//
//  Created by Presentation User on 2/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

- (void)viewDidLoad
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    imageFolder = [[resourcePath stringByAppendingPathComponent:@"Pixar-Wallpaper-Pack"] copy];
    imageArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:imageFolder
                                                                      error:NULL] retain];
    [super viewDidLoad];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [imageArray count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    NSString *imageFilename = [imageArray objectAtIndex:[indexPath row]];
    NSString *imagePath = [imageFolder stringByAppendingPathComponent:imageFilename];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    [[cell imageView] setImage:image];
    [[cell textLabel] setText:imageFilename];
    
    return cell;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Configure the cell.
//    NSString *imageFilename = [imageArray objectAtIndex:[indexPath row]];
//    NSString *imagePath = [imageFolder stringByAppendingPathComponent:imageFilename];
//    
//    [[cell textLabel] setText:imageFilename];
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//
//    dispatch_async(queue, ^{
//        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
//    
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[cell imageView] setImage:image];
//            [cell setNeedsLayout];
//        });
//    });
//    
//    return cell;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
