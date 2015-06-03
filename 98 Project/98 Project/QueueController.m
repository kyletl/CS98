//
//  QueueController.m
//  98 Project
//
//  Created by Taylor Cathcart on 4/23/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "QueueController.h"
#import "AppDelegate.h"
#import "MultipleMediaQueue.h"

@interface QueueController ()


//@property MPMediaItemCollection *playQueue;
@property (strong, nonatomic) MultipleMediaQueue *masterQueue;
@property (strong, nonatomic) MPMusicPlayerController *mMusicPlayer;
@property (strong, nonatomic) SPTAudioStreamingController *mSPTplayer;
@property BOOL MPplaying;
@property BOOL SPTplaying;
@property BOOL prevPressed;

@end

@implementation QueueController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mMusicPlayer = (AppDelegateRef).musicPlayer;
    self.mSPTplayer = (AppDelegateRef).masterSPTplayer;
    
    SPTAuth *auth = [SPTAuth defaultInstance];

    self.mSPTplayer.playbackDelegate = self;
    
    NSLog(@"Global Spotify Player: %@", (AppDelegateRef).masterSPTplayer);
    NSLog(@"Local Spotify Player: %@", self.mSPTplayer);

    
    [self.mSPTplayer loginWithSession:auth.session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
//        [self updateUI];
        
        NSURLRequest *playlistReq = [SPTPlaylistSnapshot createRequestForPlaylistWithURI:[NSURL URLWithString:@"spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4"]
                                                                             accessToken:auth.session.accessToken
                                                                                   error:nil];
        
        [[SPTRequest sharedHandler] performRequest:playlistReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
            if (error != nil) {
                NSLog(@"*** Failed to get playlist %@", error);
                return;
            }
            
            SPTPlaylistSnapshot *playlistSnapshot = [SPTPlaylistSnapshot playlistSnapshotFromData:data withResponse:response error:nil];
            
            [self.mSPTplayer playURIs:playlistSnapshot.firstTrackPage.items fromIndex:0 callback:nil];
        }];
    }];
    

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_MPNowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.mMusicPlayer];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_MPPlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.mMusicPlayer];
    
    [self.mMusicPlayer beginGeneratingPlaybackNotifications];
    
    [notificationCenter
     addObserver:  self
     selector:     @selector (handle_nextTrackPressed:)
     name:         @"NextTrackNotification"
     object:       nil];
    
    [notificationCenter
     addObserver:  self
     selector:     @selector (handle_prevTrackPressed:)
     name:         @"PrevTrackNotification"
     object:       nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) unwindFromPlayer:(UIStoryboardSegue *) segue {
    
}

- (IBAction) unwindCancelFromSpotifyPicker:(UIStoryboardSegue *) segue {
    
}

#pragma mark - PlayerController notifications

-(void)handle_nextTrackPressed:(id)notification {
    NSLog(@"next track pressed");
    if (self.masterQueue) {
        if ([self.masterQueue hasNext]) {
            if (self.MPplaying) {
                [self.mMusicPlayer stop];
            } else if (self.SPTplaying){
                [self.mSPTplayer stop:^(NSError *error) {
                    if (error != nil) {
                        NSLog(@"Error: could not stop player");
                        return;
                    }
                }];
            } else {
                [self startNextSong];
            }
        }
    }
}

-(void)handle_prevTrackPressed:(id)notification {
    NSLog(@"Prev track pressed");
    self.prevPressed = YES;
    if (self.masterQueue) {
        if ([self.masterQueue hasPrevious]) {
            if (self.MPplaying) {
                [self.mMusicPlayer stop];
            } else if (self.SPTplaying){
                [self.mSPTplayer stop:^(NSError *error) {
                    if (error != nil) {
                        NSLog(@"Error: could not stop player");
                        return;
                    }
                }];
            } else {
                self.prevPressed = NO;
                [self startPreviousSong];
            }
        }
    }
}


#pragma mark - MPMediaPlayer Notifications

- (void)handle_MPNowPlayingItemChanged:(id)notification {
    
}

- (void)handle_MPPlaybackStateChanged:(id)notification {
    if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStateStopped) {
        if (self.masterQueue) {
            if (self.MPplaying) {
                self.MPplaying = NO;
                if (self.prevPressed) {
                    self.prevPressed = NO;
                    [self startPreviousSong];
                } else {
                    [self startNextSong];
                }
            }
        }
    }
}

#pragma mark - SPTplayer streaming delegate functions

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
    if (self.masterQueue) {
        if (self.SPTplaying) {
            self.SPTplaying = NO;
            if (self.prevPressed) {
                self.prevPressed = NO;
                [self startPreviousSong];
            } else {
                [self startNextSong];
            }
        }
    }
}


#pragma mark - Next song choosing methods

-(void)startPreviousSong {
    if ([self.masterQueue hasPrevious]) {
        if ([self.masterQueue prevIsMP]) {
            MPMediaItem *previousSong = (MPMediaItem *)[self.masterQueue getPrevious];
            [self startMPSong:previousSong];
        } else if ([self.masterQueue prevIsSPT]) {
            SPTPartialTrack *previousSong = (SPTPartialTrack *)[self.masterQueue getPrevious];
            [self startSPTSong:previousSong];
        }
    }
}

-(void)startNextSong {
    if ([self.masterQueue hasNext]) {
        if ([self.masterQueue nextIsMP]) {
            MPMediaItem *nextSong = (MPMediaItem *)[self.masterQueue getNext];
            [self startMPSong: nextSong];
        } else if ([self.masterQueue nextIsSPT]) {
            SPTPartialTrack *nextSong = (SPTPartialTrack *)[self.masterQueue getNext];
            [self startSPTSong: nextSong];
        }
    }
}

-(void)startMPSong:(MPMediaItem *)song {
    NSLog(@"Starting next MP song: %@", song.title);
    MPMediaItemCollection *nextSingleQueue = [[MPMediaItemCollection alloc] initWithItems:@[song]];
    [self.mMusicPlayer setQueueWithItemCollection:nextSingleQueue];
    [self.mMusicPlayer play];
    self.MPplaying = YES;
    self.SPTplaying = NO;
}

-(void)startSPTSong:(SPTPartialTrack *)song {
    NSLog(@"Starting next SPT song: %@, %@", song.name, song.playableUri);
    [self.mSPTplayer playURIs:@[song.playableUri] fromIndex:0 callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Failed to play track %@", song.name);
            return;
        }
        if (self.mSPTplayer.isPlaying) {
            NSLog(@"spotify player %@ is playing", self.mSPTplayer);
        } else {
            NSLog(@"spotify player %@ is not playing", self.mSPTplayer);
        }
        self.MPplaying = NO;
        self.SPTplaying = YES;
    }];
    NSLog(@"outside play call spotify player %@", self.mSPTplayer);
}



#pragma mark - Media Picker Functions

- (IBAction)pressAdd:(id)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Service Select"
                                                                   message:@"Choose a service."
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* sptAction = [UIAlertAction actionWithTitle:@"Spotify"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self spotifyPicker:sender];
                                                      }];
    UIAlertAction* itAction = [UIAlertAction actionWithTitle:@"iTunes"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [self pickMusic:sender];
                                                     }];
    [alert addAction:sptAction];
    [alert addAction:itAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)spotifyPicker:(id)sender {
    [self performSegueWithIdentifier:@"EnterSpotify" sender:nil];
}


- (IBAction)pickMusic:(id)sender {
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc]
     initWithMediaTypes: MPMediaTypeAnyAudio];
    
    [picker setDelegate: self];
    [picker setAllowsPickingMultipleItems: YES];
    picker.prompt =
    NSLocalizedString (@"Add songs to play",
                       "Prompt in media item picker");
    
    [self presentViewController: picker animated: YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection {
    
    [self dismissViewControllerAnimated: YES completion:nil];
    
    
    [self updateMasterQueueWithiTunesCollection:[collection items]];
}

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated: YES completion:nil];
}


#pragma mark - Update Queue Functions

- (void) updateMasterQueueWithiTunesCollection: (NSArray *) collection {
    if (collection) {
        // if there's no playback queue yet
        if (self.masterQueue == nil) {
            self.masterQueue = [[MultipleMediaQueue alloc] initWithItems: collection];
            MPMediaItem *song = (MPMediaItem *)[self.masterQueue getCurrent];
            [self startMPSong: song];
        } else {
            [self.masterQueue addItemsFromArray: collection];
            if (([self.mMusicPlayer playbackState] == MPMusicPlaybackStateStopped) && !(self.mSPTplayer.isPlaying)) {
                [self startNextSong];
            }
        }
        NSLog(@"Master Queue: %@", self.masterQueue.playQueue);
        [self.tableView reloadData];
    }
}

- (void) updateMasterQueueWithSpotifyCollection: (NSArray *) collection {
    if (collection) {
        // if there's no playback queue yet
        if (self.masterQueue == nil) {
            self.masterQueue = [[MultipleMediaQueue alloc] initWithItems: collection];
            SPTPartialTrack *song = (SPTPartialTrack *)[self.masterQueue getCurrent];
            [self startSPTSong: song];
        } else {
            [self.masterQueue addItemsFromArray: collection];
            if (([self.mMusicPlayer playbackState] == MPMusicPlaybackStateStopped) && !(self.mSPTplayer.isPlaying)) {
                [self startNextSong];
            }
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Public Update Queue Functions

- (void) addSpotifyTracks {
    NSLog(@"returned to Queue controller, selected tracks are: %@", self.SPTtracks);
    if (self.SPTtracks) {
        [self updateMasterQueueWithSpotifyCollection:self.SPTtracks];
        self.SPTtracks = nil;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.masterQueue itemCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QueuedItem" forIndexPath:indexPath];
    
    NSString *title = [self.masterQueue getTitleAtIndex:indexPath.row];
    
    cell.textLabel.text = title;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.MPplaying = NO;
    self.SPTplaying = NO;
    [self.mMusicPlayer stop];
    [self.mSPTplayer stop:^(NSError *error) {
        if (error != nil) {
            NSLog(@"error: could not stop player");
            return;
        }
    }];
    
    if ([self.masterQueue itemAtIndexIsMP:indexPath.row]) {
        MPMediaItem *selectedSong = (MPMediaItem *)[self.masterQueue getItemAtIndexAndSetAsCurrent:indexPath.row];
        [self startMPSong: selectedSong];
    } else {
        SPTPartialTrack *selectedSong = (SPTPartialTrack *)[self.masterQueue getItemAtIndexAndSetAsCurrent:indexPath.row];
        [self startSPTSong: selectedSong];
    }
    
//    
//     Navigation logic may go here, for example:
//     Create the next view controller.
//
//    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
//    
//     Pass the selected object to the new view controller.
//    
//     Push the view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
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
