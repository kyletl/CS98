//
//  AppDelegate.m
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 4/22/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "Config.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize musicPlayer;

- (void)handle_NowPlayingItemChanged:(id)notification {
//    MPMediaItem *currentSong = self.musicPlayer.nowPlayingItem;
}

- (void)handle_PlaybackStateChanged:(id)notification {
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
//        change pause/play button to pause
    }
    if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
//        change pause/play button to play
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // instantiate a music player
    musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    if ([musicPlayer nowPlayingItem]) {
        //update album artwork / UI
    }
    
    // assign a playback queue containing all media items on the device
    [musicPlayer setQueueWithQuery: [MPMediaQuery songsQuery]];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      musicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      musicPlayer];
    
    [musicPlayer beginGeneratingPlaybackNotifications];
    
    [musicPlayer setShuffleMode: MPMusicShuffleModeOff];
    [musicPlayer setRepeatMode: MPMusicRepeatModeNone];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @kClientId;
    auth.requestedScopes = @[SPTAuthStreamingScope];
    auth.redirectURL = [NSURL URLWithString:@kCallbackURL];
    #ifdef kTokenSwapServiceURL
    auth.tokenSwapURL = [NSURL URLWithString:@kTokenSwapServiceURL];
    #endif
    #ifdef kTokenRefreshServiceURL
    auth.tokenRefreshURL = [NSURL URLWithString:@kTokenRefreshServiceURL];
    #endif
    auth.sessionUserDefaultsKey = @kSessionUserDefaultsKey;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).
        
        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }
        
        auth.session = session;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };
    
    /*
     Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */
    
    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:         musicPlayer];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:         musicPlayer];
    
    [musicPlayer endGeneratingPlaybackNotifications];
}

@end
