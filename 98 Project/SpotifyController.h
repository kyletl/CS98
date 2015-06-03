//
//  SpotifyController.h
//  98 Project
//
//  Created by Taylor Cathcart on 4/22/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SpotifyHelper.h"
#import "QueueController.h"
#import "SpotifyTrackController.h"

@interface SpotifyController : UITableViewController

-(void)addNewTracks:(NSArray *)trackArray;

@end
