//
//  UIViewController_PlayerController.h
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 4/30/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "PlayerController.h"
#import <UIKit/UIKit.h>

@interface PlayerController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@property (nonatomic, strong) MPMediaItem *nowPlaying;

@end

@implementation PlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Nothing Playing";
    self.artistLabel.text = @"";
    self.albumLabel.text = @"";
    self.nowPlaying = nil;
}

-(IBAction)playPause:(id)sender {
    if ([self.musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
        [self.musicPlayer play];
    } else if ([self.musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer pause];
    }
}

-(IBAction)next:(id)sender {
    [self.musicPlayer skipToNextItem];
}

-(IBAction)previous:(id)sender {
    [self.musicPlayer skipToPreviousItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self handleNewSession];
}

- (void)handleNewSession {
    
    self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [self.musicPlayer setQueueWithQuery: [MPMediaQuery songsQuery]];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.musicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.musicPlayer];
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
    
    [self.musicPlayer setShuffleMode: MPMusicShuffleModeOff];
    [self.musicPlayer setRepeatMode: MPMusicRepeatModeNone];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
