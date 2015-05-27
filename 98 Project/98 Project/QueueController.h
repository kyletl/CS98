//
//  QueueController.h
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 4/23/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "UIKit/UIKit.h"

@interface QueueController : UITableViewController

@property NSArray *freshQueueItems;

- (void) updateQueueWithCollection: (NSArray *) collection;

@end