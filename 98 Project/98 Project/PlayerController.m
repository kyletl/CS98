//
//  UIViewController_PlayerController.m
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 4/30/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "PlayerController.h"
#import "AppDelegate.h"

@interface PlayerController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;

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

}

-(IBAction)playPause:(id)sender {
    if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStatePaused) {
        [self.mMusicPlayer play];
    } else if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [self.mMusicPlayer pause];
    }
}

-(IBAction)next:(id)sender {
    [self.mMusicPlayer skipToNextItem];
}

-(IBAction)previous:(id)sender {
    [self.mMusicPlayer skipToPreviousItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
