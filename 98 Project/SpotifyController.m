//
//  SpotifyController.m
//  98 Project
//
//  Created by Taylor Cathcart on 4/22/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "Config.h"
#import "SpotifyController.h"
#import <Spotify/Spotify.h>
#import <Spotify/SPTDiskCache.h>

@interface SpotifyController () //<SPTAudioStreamingDelegate>

//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
//@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *coverView;
//@property (weak, nonatomic) IBOutlet UIImageView *coverView2;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

//@property (nonatomic, strong) SPTAudioStreamingController *player;

@property NSMutableArray *playlists;
@property NSMutableArray *selectedTracks;

@end

@implementation SpotifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"View did appear -- SpotifyController");
    
    [self handleNewSession];
//    self.playlists = [[NSMutableArray alloc] init];
//    self.selectedTracks = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)handleNewSession {
    
    NSLog(@"Handling new session -- SpotifyController");
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSLog(@"Got auth, attempting to fetch all user playlists");
    
    //    if (self.player == nil) {
    //        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
    //        self.player.playbackDelegate = self;
    //        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024*1024*64];
    //    }
    //
    //    [self.player loginWithSession:auth.session callback:^(NSError *error) {
    //        if (error != nil) {
    //            NSLog(@"*** Enable playback got error: %@", error);
    //            return;
    //        }
    
    [SpotifyHelper fetchAllUserPlaylistsWithSession:auth.session callback:^(NSError *err, NSArray *array) {
        if (err != nil) {
            NSLog(@"Failed unpacking or retrieving playlists with error: %@", err);
            return;
        } else {
            if (self.playlists == nil)
                self.playlists = [[NSMutableArray alloc] initWithArray:array];
            else
                [self.playlists addObjectsFromArray:array];
        }
        [self.tableView reloadData];
     }];
    
    [self.tableView reloadData];

    
//    [SPTPlaylistList playlistsForUserWithSession:auth.session callback:^(NSError *error, id object) {
//        if (error != nil) {
//            NSLog(@"Retrieve user playlists got error: %@", error);
//            return;
//        } else {
//            NSMutableArray* allPlaylists = [NSMutableArray array];
//            
//            if ([object isKindOfClass:[SPTPlaylistList class]]) {
//                SPTPlaylistList *playlistList = (SPTPlaylistList *)object; // cast to
//                
//                for (SPTPartialPlaylist *playlist in playlistList.items) {
//                    [allPlaylists addObject:playlist];
//                }
//                
//            }
//        }
//        
//    }];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReturnedPlaylist" forIndexPath:indexPath];
    SPTPartialPlaylist *p = self.playlists[indexPath.row];
    
    NSLog(@"playlist in row %ld is %@", (long)indexPath.row, p.name);
    
    cell.textLabel.text = p.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SPTAuth* auth = [SPTAuth defaultInstance];

    SPTPartialPlaylist *chosen = self.playlists[indexPath.row];
    [SpotifyHelper fetchPlaylistTracks:auth.session playlist:chosen finalCallback:^(NSError *error, NSArray *array) {
        if (error != nil) {
            NSLog(@"Received error when unpacking tracks: %@", error);
            return;
        }
        NSLog(@"retrieved tracks are %@", array);
        if (self.selectedTracks == nil) {
            self.selectedTracks = [[NSMutableArray alloc] initWithArray:array];
        } else {
            [self.selectedTracks addObjectsFromArray:array];
        }
    }];


    
//    MPMediaItem *selectedSong = [self.playQueue items][indexPath.row];
//    [self.mMusicPlayer setNowPlayingItem:selectedSong];
//    if ([self.mMusicPlayer playbackState] != MPMusicPlaybackStatePlaying) {
//        [self.mMusicPlayer play];
//    }


// Navigation logic may go here, for example:
// Create the next view controller.
//
//    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
//
// Pass the selected object to the new view controller.
//
// Push the view controller.
//    [self.navigationController pushViewController:detailViewController animated:YES];
}



#pragma mark - Navigation

//- (IBAction)spotifyFinished:(id)sender {
//    [self performSegueWithIdentifier:@"ReturnSelect" sender:nil];
//}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ReturnSelect"]) {
        UINavigationController *navctl = [segue destinationViewController];
        QueueController *qctl = (QueueController *)[navctl topViewController];
        NSLog(@"In Spotify Controller, tracks are %@", self.selectedTracks);
        qctl.SPTtracks = self.selectedTracks;
        [qctl addSpotifyTracks];
    }
}


@end
