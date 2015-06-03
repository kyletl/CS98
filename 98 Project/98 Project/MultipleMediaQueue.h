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

-(id) init;

-(id) initWithItems:(NSArray *)items;

-(void)addItemsFromArray:(NSArray *)items;

-(BOOL)hasNext;

-(BOOL)hasPrevious;

-(BOOL)nextIsMP;

-(BOOL)nextIsSPT;

-(BOOL)itemAtIndexIsMP:(int)index;

-(BOOL)itemAtIndexIsSPT:(int)index;

-(NSObject *)getCurrent;

-(NSObject *)getNext;

-(NSObject *)getPrevious;

-(NSObject *)getItemAtIndex:(int)index;

-(NSObject *)getItemAtIndexAndSetAsCurrent:(int)index;

-(NSString *)getTitleAtIndex:(int)index;

-(NSString *)getArtistAtIndex:(int)index;

-(NSString *)getAlbumAtIndex:(int)index;
@end
