//
//  SpotifyTrackController.m
//  98 Project
//
//  Created by Sudikoff Lab iMac on 6/3/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "SpotifyTrackController.h"

@interface SpotifyTrackController ()

@property NSMutableArray *tracksChosen;
@property NSMutableArray *tracksAvailable;

@end

@implementation SpotifyTrackController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"View did appear -- SpotifyController");
    
    SPTAuth* auth = [SPTAuth defaultInstance];
    
        [SpotifyHelper fetchPlaylistTracks:auth.session playlist:self.currList finalCallback:^(NSError *error, NSArray *array) {
            if (error != nil) {
                NSLog(@"Received error when unpacking tracks: %@", error);
                return;
            }
            NSLog(@"retrieved tracks are %@", array);
            self.tracksAvailable = [[NSMutableArray alloc] initWithArray:array];
            
            [self.tableView reloadData];

        }];
    

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tracksAvailable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReturnedPlaylist" forIndexPath:indexPath];
    SPTPartialTrack *trk = self.tracksAvailable[indexPath.row];
    
    NSLog(@"playlist in row %ld is %@", (long)indexPath.row, trk.name);
    
    cell.textLabel.text = trk.name;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tracksChosen == nil) {
        self.tracksChosen = [[NSMutableArray alloc] init];
    }
    if (![self.tracksChosen containsObject:self.tracksAvailable[indexPath.row]]) {
        [self.tracksChosen addObject:self.tracksAvailable[indexPath.row]];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //     Get the new view controller using [segue destinationViewController].
    //     Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"SpotifyTracksFinished"]) {
//        UINavigationController *navctl = [segue destinationViewController];
//        QueueController *qctl = (QueueController *)[navctl topViewController];
        
        SpotifyController *sctl = (SpotifyController *)[segue destinationViewController];
        NSLog(@"Spotify tracks are finished with: %@", self.tracksChosen);
        [sctl addNewTracks:[self.tracksChosen copy]];
    }
    
        self.tracksChosen = nil;
    
}


@end
