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

@property (nonatomic, strong) MPMediaItem *nowPlaying;

@end

@implementation PlayerController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Nothing Playing";
    self.artistLabel.text = @"";
    self.albumLabel.text = @"";
    self.nowPlaying = nil;
    self.mMusicPlayer = (AppDelegateRef).musicPlayer;
    
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
}

-(void)handle_NowPlayingItemChanged:(id)notification {
    self.nowPlaying = self.mMusicPlayer.nowPlayingItem;
    [self updateUI];
}

-(void)handle_PlaybackStateChanged:(id)notification {
    MPMusicPlaybackState currentState = [self.mMusicPlayer playbackState];
    if (currentState == MPMusicPlaybackStatePlaying) {
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}


-(IBAction)playPause:(id)sender {
    if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [self.mMusicPlayer pause];
    } else if (self.nowPlaying) {
        [self.mMusicPlayer play];
    }
}

-(IBAction)next:(id)sender {
    [self.mMusicPlayer skipToNextItem];
}

-(IBAction)previous:(id)sender {
    [self.mMusicPlayer skipToPreviousItem];
}

- (void)updateUI {
    if (self.nowPlaying) {
        self.titleLabel.text = self.nowPlaying.title;
        self.artistLabel.text = self.nowPlaying.artist;
        self.albumLabel.text = self.nowPlaying.albumTitle;
        //        if (!self.coverView) {
        //            [self.coverView initWithImage: [self.nowPlaying.artwork imageWithSize:]];
        //      }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateUI];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
