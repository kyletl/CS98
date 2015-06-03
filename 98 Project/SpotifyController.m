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
@property NSMutableArray *selectedPlaylists;

@end

@implementation SpotifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self handleNewSession];
//    self.playlists = [[NSMutableArray alloc] init];
//    self.selectedPlaylists = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
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
    
    [SpotifyController fetchAllUserPlaylistsWithSession:auth.session callback:^(NSError *err, NSArray *array) {
        if (err != nil) {
            NSLog(@"Failed unpacking or retrieving playlists with error: %@", err);
            return;
        } else {
            if (self.playlists == nil) {
                self.playlists = [[NSMutableArray alloc] init];
            }
            
            for (SPTPartialPlaylist *pl in array) {
                [self.playlists addObject:pl.name];
            }
            
        }
        
        
    }];
    
    
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

/* utility helpers for unpacking requested playlists */
+ (void)fetchAllUserPlaylistsWithSession:(SPTSession *)session callback:(void (^)(NSError *, NSArray *))callback
{
    [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, id object) {
        [SpotifyController didFetchListPageForSession:session finalCallback:callback error:error object:object allPlaylists:[NSMutableArray array]];
    }];
}

+ (void)didFetchListPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError*, NSArray*))finalCallback error:(NSError *)error object:(id)object allPlaylists:(NSMutableArray *)allPlaylists
{
    if (error != nil) {
        finalCallback(error, nil);
    } else {
        if ([object isKindOfClass:[SPTPlaylistList class]]) {
            SPTPlaylistList *playlistList = (SPTPlaylistList *)object;
            
            for (SPTPartialPlaylist *playlist in playlistList.items) {
                [allPlaylists addObject:playlist];
            }
            
            if (playlistList.hasNextPage) {
                [playlistList requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [SpotifyController didFetchListPageForSession:session
                                                           finalCallback:finalCallback
                                                                   error:error
                                                                  object:object
                                                            allPlaylists:allPlaylists];
                }];
            } else {
                finalCallback(nil, [allPlaylists copy]);
            }
        }
    }
}

#pragma mark - Table view

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.playlists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReturnedPlaylist" forIndexPath:indexPath];
    NSString *pname = self.playlists[indexPath.row];
    
    NSLog(@"playlist in row %ld is %@", (long)indexPath.row, pname);
    
    cell.textLabel.text = pname;
    
    return cell;
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
