//
//  SpotifyController.h
//  98 Project
//
//  Created by Taylor Cathcart on 4/22/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SpotifyController : UITableViewController

+ (void)fetchAllUserPlaylistsWithSession:(SPTSession *)session callback:(void (^)(NSError *, NSArray *))callback;

+ (void)didFetchListPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError*, NSArray*))finalCallback error:(NSError *)error object:(id)object allPlaylists:(NSMutableArray *)allPlaylists;

@end
