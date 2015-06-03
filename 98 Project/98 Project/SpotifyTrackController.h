//
//  SpotifyTrackController.h
//  98 Project
//
//  Created by Sudikoff Lab iMac on 6/3/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppDelegate.h>
#import "SpotifyHelper.h"
#import "SpotifyController.h"

@interface SpotifyTrackController : UITableViewController

@property (weak, nonatomic) SPTPartialPlaylist *currList;

@end
