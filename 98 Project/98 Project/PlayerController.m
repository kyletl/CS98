//
//  UIViewController_PlayerController.m
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 4/30/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "PlayerController.h"

@interface PlayerController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;

@property (nonatomic, strong) MPMusicPlayerController *mMusicPlayer;
@property (nonatomic, strong) SPTAudioStreamingController *mSPTplayer;

@end

@implementation PlayerController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.mMusicPlayer = (AppDelegateRef).musicPlayer;
    self.mSPTplayer = (AppDelegateRef).masterSPTplayer;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.mMusicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.mMusicPlayer];
    
    [self.mMusicPlayer beginGeneratingPlaybackNotifications];
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self updateUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Player Notifications

-(void)handle_NowPlayingItemChanged:(id)notification {
//    NSLog(@"handling now playing item change %@", [self.mMusicPlayer nowPlayingItem]);
    [self updateUI];
}

-(void)handle_PlaybackStateChanged:(id)notification {
//    NSLog(@"handling playbackstate changed %ld", [self.mMusicPlayer playbackState]);
    MPMusicPlaybackState currentState = [self.mMusicPlayer playbackState];
    if (currentState == MPMusicPlaybackStatePlaying) {
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

#pragma mark - Player Functions

-(IBAction)playPause:(id)sender {
    if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [self.mMusicPlayer pause];
    } else if ([self.mMusicPlayer nowPlayingItem]) {
        [self.mMusicPlayer play];
    }
}

-(IBAction)next:(id)sender {
//    [self.mMusicPlayer skipToNextItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NextTrackNotification" object:nil];
}

-(IBAction)previous:(id)sender {
//    [self.mMusicPlayer skipToPreviousItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PrevTrackNotification" object:nil];
}

-(void)updateUI {
    MPMediaItem *nowPlaying = [self.mMusicPlayer nowPlayingItem];
    if (nowPlaying) {
        if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
            [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        }
        self.titleLabel.text = nowPlaying.title;
        self.artistLabel.text = nowPlaying.artist;
        self.albumLabel.text = nowPlaying.albumTitle;
        //        if (!self.coverView) {
        //            [self.coverView initWithImage: [self.nowPlaying.artwork imageWithSize:]];
        //      }
    } else {
        self.titleLabel.text = @"Nothing Playing";
        self.artistLabel.text = @"";
        self.albumLabel.text = @"";
    }
}




 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
//     if (sender == self.doneButton) {
//         return;
//     }
 }
 

@end
