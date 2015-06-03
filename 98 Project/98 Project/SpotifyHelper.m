//
//  SpotifyHelper.m
//  98 Project
//
//  Created by Sudikoff Lab iMac on 6/3/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotifyHelper.h"

@interface SpotifyHelper()

@end

@implementation SpotifyHelper

/* utility helpers for unpacking requested playlists */
+ (void)fetchAllUserPlaylistsWithSession:(SPTSession *)session callback:(void (^)(NSError *, NSArray *))callback
{
    [SPTPlaylistList playlistsForUserWithSession:session callback:^(NSError *error, id object) {
        [SpotifyHelper didFetchListPageForSession:session finalCallback:callback error:error object:object allPlaylists:[NSMutableArray array]];
    }];
}

+ (void)didFetchListPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError*, NSArray*))finalCallback error:(NSError *)error object:(id)object allPlaylists:(NSMutableArray *)allPlaylists
{
    if (error != nil) {
        finalCallback(error, nil);
    } else {
        NSLog(@"Received playlists from server");
        if ([object isKindOfClass:[SPTPlaylistList class]]) {
            SPTPlaylistList *playlistList = (SPTPlaylistList *)object;
            
            for (SPTPartialPlaylist *playlist in playlistList.items) {
                NSLog(@"Adding playlist: %@", playlist.name);
                [allPlaylists addObject:playlist];
            }
            
            if (playlistList.hasNextPage) {
                NSLog(@"playlist has next page, opening");
                [playlistList requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [SpotifyHelper didFetchListPageForSession:session
                                                    finalCallback:finalCallback
                                                            error:error
                                                           object:object
                                                     allPlaylists:allPlaylists];
                }];
            } else {
                finalCallback(nil, [allPlaylists copy]);
            }
        } else {
            NSLog(@"Received non-SPTPlaylistList from server");
            return;
        }
    }
}

+ (void)fetchPlaylistTracks:(SPTSession *)session playlist:(SPTPartialPlaylist *)playlist finalCallback:(void (^)(NSError *, NSArray *))finalCallback
{
    [SPTPlaylistSnapshot playlistWithURI:playlist.uri session:session callback:^(NSError *error, id object) {
        [SpotifyHelper didFetchTrackPageForSession:session finalCallback:finalCallback error:error object:object allTracks:[NSMutableArray array]];
    }];
}

+ (void)didFetchTrackPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError *error, NSArray *))finalCallback error:(NSError *)error object:(id)object allTracks:(NSMutableArray *)allTracks
{
    if (error != nil) {
        finalCallback(error, nil);
        return;
    } else {
        NSLog(@"Received playlist snapshot from server");
        if ([object isKindOfClass:[SPTPlaylistSnapshot class]]) {
            SPTPlaylistSnapshot *playlist = (SPTPlaylistSnapshot *)object;
            SPTListPage *page = playlist.firstTrackPage;
            
            for (SPTPartialTrack *track in page.items) {
                NSLog(@"Adding track: %@", track.name);
                [allTracks addObject:track];
            }
            
            finalCallback(error, [allTracks copy]);
            
            if (page.hasNextPage) {
                [page requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [SpotifyHelper didFetchNextTrackPageForSession:session finalCallback:finalCallback error:error object:object allTracks:allTracks];
                }];
                 
            }
        } else {
            NSLog(@"Received non-playlist snapshot from snapshot request");
            return;
        }
    
    }
}

+ (void)didFetchNextTrackPageForSession:(SPTSession *)session finalCallback:(void (^)(NSError *error, NSArray *))finalCallback error:(NSError *)error object:(id)object allTracks:(NSMutableArray *)allTracks {
    if (error != nil) {
        finalCallback(error, nil);
        return;
    } else {
        NSLog(@"Received new page from server");
        if ([object isKindOfClass:[SPTListPage class]]) {
            SPTListPage *page = (SPTListPage *)object;
            
            for (SPTPartialTrack *track in page.items) {
                NSLog(@"Adding track: %@", track.name);
                [allTracks addObject:track];
            }
            
            if (page.hasNextPage) {
                [page requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [SpotifyHelper didFetchNextTrackPageForSession:session finalCallback:finalCallback error:error object:object allTracks:allTracks];
                }];
            } else {
                finalCallback(nil, [allTracks copy]);
            }
        } else {
            NSLog(@"Received non-list page from next page request");
            return;
        }
    }
    
}

@end