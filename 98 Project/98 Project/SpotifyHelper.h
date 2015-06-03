//
//  SpotifyController.h
//  98 Project
//
//  Created by Taylor Cathcart on 4/22/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SpotifyHelper : NSObject

+ (void)fetchAllUserPlaylistsWithSession:(SPTSession *)session callback:(void (^)(NSError *, NSArray *))callback;

+ (void)didFetchListPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError*, NSArray*))finalCallback error:(NSError *)error object:(id)object allPlaylists:(NSMutableArray *)allPlaylists;

+ (void)fetchPlaylistTracks:(SPTSession *)session playlist:(SPTPartialPlaylist *)playlist callback:(void (^)(NSError *, NSArray *))finalCallback;

+ (void)didFetchTrackPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError *, NSArray*))finalCallback error:(NSError *)error allTracks:(NSMutableArray *)array;

+ (void)didFetchNextTrackPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError *, NSArray*))finalCallback error:(NSError *)error object:(id)object allTracks:(NSMutableArray *)allTracks;

@end
