//
//  MultipleMediaQueue.h
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 6/3/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Spotify/Spotify.h>

@interface MultipleMediaQueue : NSObject

@property NSMutableArray *playQueue;

-(NSInteger) itemCount;

-(id) init;

-(id) initWithItems:(NSArray *)items;

-(void)addItemsFromArray:(NSArray *)items;

-(BOOL)hasNext;

-(BOOL)hasPrevious;

-(BOOL)nextIsMP;

-(BOOL)nextIsSPT;

-(BOOL)prevIsMP;

-(BOOL)prevIsSPT;

-(BOOL)itemAtIndexIsMP:(NSInteger)index;

-(BOOL)itemAtIndexIsSPT:(NSInteger)index;

-(NSObject *)getCurrent;

-(NSObject *)getNext;

-(NSObject *)getPrevious;

-(NSObject *)getItemAtIndex:(NSInteger)index;

-(NSObject *)getItemAtIndexAndSetAsCurrent:(NSInteger)index;

-(NSString *)getTitleAtIndex:(NSInteger)index;

-(NSString *)getArtistAtIndex:(NSInteger)index;

-(NSString *)getAlbumAtIndex:(NSInteger)index;
@end
