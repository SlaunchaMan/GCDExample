//
//  JKCallbacksTableViewCell.m
//  GCDExample
//
//  Created by Jeff Kelley on 8/12/11.
//  Copyright (c) 2011 Detroit Labs. All rights reserved.
//

#import "JKCallbacksTableViewCell.h"


NSString * const kJKPrepareForReuseNotification = @"JKCallbacksTableViewCell_PrepareForReuse";

@implementation JKCallbacksTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) {
		[[self imageView] addObserver:self
						   forKeyPath:@"image"
							  options:NSKeyValueObservingOptionOld
							  context:NULL];
	}
	
	return self;
}

// The reason we’re observing changes is that if you create a table view cell, return it to the
// table view, and then later add an image (perhaps after doing some background processing), you
// need to call -setNeedsLayout on the cell for it to add the image view to its view hierarchy. We
// asked the change dictionary to contain the old value because this only needs to happen if the
// image was previously nil.
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	if (object == [self imageView] &&
		[keyPath isEqualToString:@"image"] &&
		([change objectForKey:NSKeyValueChangeOldKey] == nil ||
		 [change objectForKey:NSKeyValueChangeOldKey] == [NSNull null])) {
		[self setNeedsLayout];
	}
}

- (void)prepareForReuse
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kJKPrepareForReuseNotification
														object:self];
	
	[super prepareForReuse];
}

@end
