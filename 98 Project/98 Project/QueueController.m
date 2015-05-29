//
//  QueueController.m
//  98 Project
//
//  Created by Taylor Cathcart on 4/23/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "QueueController.h"
#import "AppDelegate.h"

@interface QueueController ()

@property MPMediaItemCollection *playQueue;
@property (weak, nonatomic) MPMusicPlayerController *mMusicPlayer;

@end

@implementation QueueController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mMusicPlayer = (AppDelegateRef).musicPlayer;
    self.playQueue = nil;
    self.freshQueueItems = [[NSArray alloc] init];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
}





- (IBAction)unwindFromPicker:(UIStoryboardSegue *) segue {
    NSLog(@"got to unwind");
    if([segue.identifier isEqualToString: @"updateQueueSegue"]) {
        NSLog(@"segue is %@", segue.identifier);
        [self updateQueueWithCollection: self.freshQueueItems];
    }
}


- (void) updateQueueWithCollection: (NSArray *) collection {

    NSLog(@"made it to queue controller with %@", collection);
    // Add 'collection' to the music player's playback queue, but only if
    //    the user chose at least one song to play.
    if (collection) {

//        // If there's no playback queue yet...
        if (self.playQueue == nil) {
            self.playQueue = [[MPMediaItemCollection alloc] initWithItems:collection];
            [self.mMusicPlayer setQueueWithItemCollection: self.playQueue];
            [self.mMusicPlayer play];
            NSLog(@"queue was nil, now %@", self.playQueue);
        } else {
//             Obtain the music player's state so it can be restored after
//                updating the playback queue.
            BOOL wasPlaying = NO;
            if (self.mMusicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
                wasPlaying = YES;
            }

            // Save the now-playing item and its current playback time.
            MPMediaItem *nowPlayingItem        = self.mMusicPlayer.nowPlayingItem;
            NSTimeInterval currentPlaybackTime = self.mMusicPlayer.currentPlaybackTime;

            // Combine the previously-existing media item collection with
            //    the new one
            NSMutableArray *combinedMediaItems = [[self.playQueue items] mutableCopy];
            NSArray *newMediaItems = collection;
            [combinedMediaItems addObjectsFromArray: newMediaItems];

            [self setPlayQueue:
             [MPMediaItemCollection collectionWithItems:
              (NSArray *) combinedMediaItems]];

            [self.mMusicPlayer setQueueWithItemCollection: self.playQueue];

            // Restore the now-playing item and its current playback time.
            self.mMusicPlayer.nowPlayingItem      = nowPlayingItem;
            self.mMusicPlayer.currentPlaybackTime = currentPlaybackTime;

            if (wasPlaying) {
                [self.mMusicPlayer play];
            }
            NSLog(@"queue not nil, now %@", self.playQueue);
        }
        [self.tableView reloadData];
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playQueue count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"queuedTrack" forIndexPath:indexPath];
    
    MPMediaItem *song = [[self.playQueue items] objectAtIndex:indexPath.row];
    
    NSLog(@"song in row %ld is %@", (long)indexPath.row, song.title);
    
    cell.textLabel.text = song.title;
    
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
