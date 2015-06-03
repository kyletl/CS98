//
//  QueueController.h
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 4/23/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Spotify/Spotify.h>

@interface QueueController : UITableViewController <MPMediaPickerControllerDelegate, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

- (void) addSpotifyTracks;

@property (nonatomic, strong) NSArray *SPTtracks;

@end