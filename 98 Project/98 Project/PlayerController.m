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
@property NSString *currentPlayer;

@end

@implementation PlayerController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.mMusicPlayer = (AppDelegateRef).musicPlayer;
    self.mSPTplayer = (AppDelegateRef).masterSPTplayer;
    self.currentPlayer = @"";
    
//    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//    
//    [notificationCenter
//     addObserver: self
//     selector:    @selector (handle_NowPlayingItemChanged:)
//     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//     object:      self.mMusicPlayer];
//    
//    [notificationCenter
//     addObserver: self
//     selector:    @selector (handle_PlaybackStateChanged:)
//     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
//     object:      self.mMusicPlayer];
//    
//    [self.mMusicPlayer beginGeneratingPlaybackNotifications];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver:   self
     selector:      @selector (handle_newMPItemPlaying:)
     name:          @"newMPItemPlaying"
     object:        nil];
    
    
    [notificationCenter
     addObserver:   self
     selector:      @selector (handle_newSPTItemPlaying:)
     name:          @"newSPTItemPlaying"
     object:        nil];
    
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

-(void)handle_newMPItemPlaying:(id)notification {
    NSLog(@"newMP item notification");
    self.currentPlayer = @"MP";
    [self updateUI];
}

-(void)handle_newSPTItemPlaying:(id)notification {
    NSLog(@"newSPT item notification");
    self.currentPlayer = @"SPT";
    [self updateUI];
}


//-(void)handle_NowPlayingItemChanged:(id)notification {
////    NSLog(@"handling now playing item change %@", [self.mMusicPlayer nowPlayingItem]);
//    [self updateUI];
//}
//
//-(void)handle_PlaybackStateChanged:(id)notification {
////    NSLog(@"handling playbackstate changed %ld", [self.mMusicPlayer playbackState]);
//    MPMusicPlaybackState currentState = [self.mMusicPlayer playbackState];
//    if (currentState == MPMusicPlaybackStatePlaying) {
//        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
//    } else {
//        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
//    }
//}

#pragma mark - Player Functions

-(IBAction)playPause:(id)sender {
    if ([self.currentPlayer  isEqual: @"MP"]) {
        if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
            [self.mMusicPlayer pause];
        } else if ([self.mMusicPlayer nowPlayingItem]) {
            [self.mMusicPlayer play];
        }
    } else  if ([self.currentPlayer isEqual: @"SPT"]){
        [self.mSPTplayer setIsPlaying:!self.mSPTplayer.isPlaying callback:nil];
    }
}

-(IBAction)next:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NextTrackNotification" object:nil];
}

-(IBAction)previous:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PrevTrackNotification" object:nil];
}

-(void)updateUI {
    self.titleLabel.text = @"Nothing Playing";
    self.artistLabel.text = @"";
    self.albumLabel.text = @"";
    
    if ([self.currentPlayer isEqual: @"MP"]) {
        MPMediaItem *nowPlaying = [self.mMusicPlayer nowPlayingItem];
        if (nowPlaying) {
            self.titleLabel.text = nowPlaying.title;
            self.artistLabel.text = nowPlaying.artist;
            self.albumLabel.text = nowPlaying.albumTitle;
        }
        //        if (!self.coverView) {
        //            [self.coverView initWithImage: [self.nowPlaying.artwork imageWithSize:]];
        //      }
    } else if ([self.currentPlayer isEqual: @"SPT"]) {
        NSDictionary *data = self.mSPTplayer.currentTrackMetadata;
        if (data) {
            self.titleLabel.text = [data objectForKey:SPTAudioStreamingMetadataTrackName];
            self.artistLabel.text = [data objectForKey:SPTAudioStreamingMetadataArtistName];
            self.albumLabel.text = [data objectForKey:SPTAudioStreamingMetadataAlbumName];
        }
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
