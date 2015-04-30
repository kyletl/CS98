//
//  iTunesController.m
//  98 Project
//
//  Created by Taylor Cathcart on 4/23/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "iTunesController.h"

@interface iTunesController ()
@property (weak, nonatomic) IBOutlet UIButton *pickerStart;
@property (weak, nonatomic) MPMusicPlayerController *mMusicPlayer;
@property (weak, nonatomic) IBOutlet UILabel *test;

@end

@implementation iTunesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mMusicPlayer = (AppDelegateRef).musicPlayer;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection {
    
    [self dismissModalViewControllerAnimated: YES];
    [self updateQueueWithCollection: collection];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    [self dismissModalViewControllerAnimated: YES];
}

- (void) updateQueueWithCollection: (MPMediaItemCollection *) collection {
    
    // Add 'collection' to the music player's playback queue, but only if
    //    the user chose at least one song to play.
    if (collection) {
        
        // If there's no playback queue yet...
        if (userMediaItemCollection == nil) {
            [self setUserMediaItemCollection: collection];
            [self.mMusicPlayer setQueueWithItemCollection: userMediaItemCollection];
            [self.mMusicPlayer play];
            
            // Obtain the music player's state so it can be restored after
            //    updating the playback queue.
        } else {
            BOOL wasPlaying = NO;
            if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
                wasPlaying = YES;
            }
            
            // Save the now-playing item and its current playback time.
            MPMediaItem *nowPlayingItem        = musicPlayer.nowPlayingItem;
            NSTimeInterval currentPlaybackTime = musicPlayer.currentPlaybackTime;
            
            // Combine the previously-existing media item collection with
            //    the new one
            NSMutableArray *combinedMediaItems =
            [[userMediaItemCollection items] mutableCopy];
            NSArray *newMediaItems = [mediaItemCollection items];
            [combinedMediaItems addObjectsFromArray: newMediaItems];
            
            [self setUserMediaItemCollection:
             [MPMediaItemCollection collectionWithItems:
              (NSArray *) combinedMediaItems]];
            
            [musicPlayer setQueueWithItemCollection: userMediaItemCollection];
            
            // Restore the now-playing item and its current playback time.
            musicPlayer.nowPlayingItem      = nowPlayingItem;
            musicPlayer.currentPlaybackTime = currentPlaybackTime;
            
            if (wasPlaying) {
                [musicPlayer play];
            }
        }
    }
}





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if (sender != self.pickerStart) return;
    
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc]
     initWithMediaTypes: MPMediaTypeAnyAudio];
    
    [picker setDelegate: self];
    [picker setAllowsPickingMultipleItems: YES];
    picker.prompt =
    NSLocalizedString (@"Add songs to play",
                       "Prompt in media item picker");
    
    [self presentModalViewController: picker animated: YES];
//    [picker release];
    
    
}

@end
