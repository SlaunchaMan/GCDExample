//
//  JKCallbacksTableViewCell.h
//  GCDExample
//
//  Created by Jeff Kelley on 8/12/11.
//  Copyright (c) 2011 Detroit Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString * const kJKPrepareForReuseNotification;


// This class doesn’t do much. I’m going to use it to send some NSNotifications when the table view
// cell is reused, etc. in order to avoid having application logic in the table view cell, which is,
// after all, the V in MVC.
@interface JKCallbacksTableViewCell : UITableViewCell

@end
