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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)handleNewSession {
    
    NSLog(@"Handling new session -- SpotifyController");
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSLog(@"Got auth, attempting to fetch all user playlists");
    
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

}

-(void)addNewTracks:(NSArray *)trackArray {
    if (self.selectedTracks == nil) {
        self.selectedTracks = [[NSMutableArray alloc] initWithArray:trackArray];
    } else {
        [self.selectedTracks addObjectsFromArray:trackArray];
    }
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
    
    SPTPartialPlaylist *chosen = self.playlists[indexPath.row];
    
    // navigate to the detail view for track selection
    [self performSegueWithIdentifier:@"SpotifyTracks" sender:chosen];
    


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

- (IBAction) unwindDoneFromTrackView:(UIStoryboardSegue *) segue {
    return;
}

- (IBAction) unwindCancelFromTrackView:(UIStoryboardSegue *) segue {
    return;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"ReturnSelect"]) {
        QueueController *qctl = (QueueController *)[segue destinationViewController];
        NSLog(@"In Spotify Controller, tracks are %@", self.selectedTracks);
        qctl.SPTtracks = self.selectedTracks;
    } else if ([[segue identifier] isEqualToString:@"SpotifyTracks"]) {
        SpotifyTrackController *trkctl = [segue destinationViewController];
        trkctl.currList = (SPTPartialPlaylist *) sender;
        NSLog(@"In Spotify controller, moving to tracks view");
    }
}


@end
