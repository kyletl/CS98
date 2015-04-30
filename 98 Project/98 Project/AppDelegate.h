//
//  AppDelegate.h
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 4/22/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define AppDelegateRef (AppDelegate *)[UIApplication sharedApplication].delegate

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;

@end

