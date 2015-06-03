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


@property MPMediaItemCollection *playQueue;
@property MultipleMediaQueue *masterQueue;
@property (weak, nonatomic) MPMusicPlayerController *mMusicPlayer;
@property (weak, nonatomic) SPTAudioStreamingController *mSPTplayer;

@end

@implementation QueueController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mMusicPlayer = (AppDelegateRef).musicPlayer;
    self.mSPTplayer = (AppDelegateRef).masterSPTplayer;
    self.mSPTplayer.playbackDelegate = self;

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction) unwindFromPlayer:(UIStoryboardSegue *) segue {
    
}


#pragma mark - MPMediaPlayer Notifications

- (void)handle_MPNowPlayingItemChanged:(id)notification {
    
}

- (void)handle_MPPlaybackStateChanged:(id)notification {
    if ([self.mMusicPlayer playbackState] == MPMusicPlaybackStateStopped) {
        if (self.masterQueue) {
            if ([self.masterQueue hasNext]) {
                [self startNextSong];
            }
        }
    }
}

#pragma mark - SPTplayer streaming delegate functions

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didStopPlayingTrack:(NSURL *)trackUri {
    if (self.masterQueue) {
        if ([self.masterQueue hasNext]) {
            [self startNextSong];
        }
    }
}


#pragma mark - Next song choosing methods

-(void)startNextSong {
    if ([self.masterQueue hasNext]) {
        NSObject *nextSong = [self.masterQueue getNext];
        if ([self.masterQueue nextIsMP]) {
            [self startMPSong:(MPMediaItem *)nextSong];
        } else {
            [self startSPTSong:(SPTPartialTrack *)nextSong];
        }
    }
}

-(void)startMPSong:(MPMediaItem *)nextSong {
    NSLog(@"Starting next MP song: %@", nextSong.title);
    MPMediaItemCollection *nextSingleQueue = [[MPMediaItemCollection alloc] initWithItems:@[nextSong]];
    [self.mMusicPlayer setQueueWithItemCollection:nextSingleQueue];
    [self.mMusicPlayer play];
}

-(void)startSPTSong:(SPTPartialTrack *)nextSong {
    NSLog(@"Starting next SPT song: %@", nextSong.name);
    [self.mSPTplayer playURIs:@[nextSong.playableUri] fromIndex:0 callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Failed to play track %@", nextSong.name);
            return;
        }
    }];
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
//            MPMediaItemCollection *singleSongQueue = [[MPMediaItemCollection alloc] initWithItems:@[song]];
//            [self.mMusicPlayer setQueueWithItemCollection:singleSongQueue];
//            [self.mMusicPlayer play];
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
//            [self.mSPTplayer playURIs:@[song.playableUri] fromIndex:0 callback:^(NSError *error) {
//                if (error != nil) {
//                    NSLog(@"Failed to play track %@", song.name);
//                    return;
//                }
//            }];
        } else {
            [self.masterQueue addItemsFromArray: collection];
            if (([self.mMusicPlayer playbackState] == MPMusicPlaybackStateStopped) && !(self.mSPTplayer.isPlaying)) {
                [self startNextSong];
            }
        }
    }
}

#pragma mark - Public Update Queue Functions

- (void) addSpotifyTracks:(NSArray *)selectedTracks {
    [self updateMasterQueueWithSpotifyCollection:selectedTracks];
}

//- (void) updateQueueWithCollection: (NSArray *) collection {
//
//    // Add 'collection' to the music player's playback queue, but only if
//    //    the user chose at least one song to play.
//    if (collection) {
//
////        // If there's no playback queue yet...
//        if (self.playQueue == nil) {
//            self.playQueue = [[MPMediaItemCollection alloc] initWithItems:collection];
//            [self.mMusicPlayer setQueueWithItemCollection: self.playQueue];
//            [self.mMusicPlayer play];
//            NSLog(@"queue was nil, now %@", self.playQueue);
//        } else {
////             Obtain the music player's state so it can be restored after
////                updating the playback queue.
//            BOOL wasPlaying = NO;
//            if (self.mMusicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
//                wasPlaying = YES;
//            }
//
//            // Save the now-playing item and its current playback time.
//            MPMediaItem *nowPlayingItem        = self.mMusicPlayer.nowPlayingItem;
//            NSTimeInterval currentPlaybackTime = self.mMusicPlayer.currentPlaybackTime;
//
//            // Combine the previously-existing media item collection with
//            //    the new one
//            NSMutableArray *combinedMediaItems = [[self.playQueue items] mutableCopy];
//            NSArray *newMediaItems = collection;
//            [combinedMediaItems addObjectsFromArray: newMediaItems];
//
//            [self setPlayQueue:
//             [MPMediaItemCollection collectionWithItems:
//              (NSArray *) combinedMediaItems]];
//
//            [self.mMusicPlayer setQueueWithItemCollection: self.playQueue];
//
//            // Restore the now-playing item and its current playback time.
//            self.mMusicPlayer.nowPlayingItem      = nowPlayingItem;
//            self.mMusicPlayer.currentPlaybackTime = currentPlaybackTime;
//
//            if (wasPlaying) {
//                [self.mMusicPlayer play];
//            }
//            NSLog(@"queue not nil, now %@", self.playQueue);
//        }
//        [self.tableView reloadData];
//    }
//}



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
    
    NSLog(@"song in row %ld is %@", (long)indexPath.row, title);
    
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
