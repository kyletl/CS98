//
//  MultipleMediaQueue.m
//  98 Project
//
//  Created by Kyle Tessier-Lavigne on 6/3/15.
//  Copyright (c) 2015 Kyle Tessier-Lavigne. All rights reserved.
//

#import "MultipleMediaQueue.h"

@interface MultipleMediaQueue ()

@property int current;

@end

@implementation MultipleMediaQueue

-(NSInteger) itemCount {
    return [self.playQueue count];
}

-(id) init {
    self = [super init];
    if (self) {
        self.current = 0;
        self.playQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithItems:(NSArray *) items {
    self = [super init];
    if (self) {
        self.current = 0;
        if (self.playQueue == nil) {
            self.playQueue = [[NSMutableArray alloc] initWithArray: items];
        }
    }
    return self;
}

-(void)addItemsFromArray:(NSArray *)items {
    if (self.playQueue) {
        [self.playQueue addObjectsFromArray:items];
    }
}

-(BOOL)hasNext {
    if (self.current < ([self.playQueue count] - 1)) {
        return YES;
    }
    return NO;
}

-(BOOL)hasPrevious {
    if (self.current > 0) {
        return YES;
    }
    return NO;
}

-(BOOL)nextIsMP {
    if ([self hasNext]) {
        return [self itemAtIndexIsMP:(self.current + 1)];
    }
    return NO;
}

-(BOOL)nextIsSPT {
    if ([self hasNext]) {
        return [self itemAtIndexIsSPT:(self.current + 1)];
    }
    return NO;
}

-(BOOL)prevIsMP {
    if ([self hasPrevious]) {
        return [self itemAtIndexIsMP:(self.current - 1)];
    }
    return NO;
}

-(BOOL)prevIsSPT {
    if ([self hasPrevious]) {
        return [self itemAtIndexIsSPT:(self.current - 1)];
    }
    return NO;
}

-(BOOL)itemAtIndexIsMP:(NSInteger)index {
    if (index < [self.playQueue count] && index > -1) {
        NSObject *item = self.playQueue[index];
        return [item isKindOfClass: [MPMediaItem class]];
    }
    return NO;
}


//at the moment, spotify tracks are stored as their URI strings
-(BOOL)itemAtIndexIsSPT:(NSInteger)index {
    if (index < [self.playQueue count] && index > -1) {
        NSObject *item = self.playQueue[index];
        return [item isKindOfClass: [SPTPartialTrack class]];
    }
    return NO;
}

-(NSObject *)getCurrent {
    if ([self.playQueue count] > 0) {
        return self.playQueue[self.current];
    }
    return nil;
}

-(NSObject *)getNext {
    if ([self hasNext]) {
        self.current++;
        NSLog(@"Current: %d", self.current);
        return self.playQueue[self.current];
    }
    return nil;
}

-(NSObject *)getPrevious {
    if ([self hasPrevious]) {
        self.current--;
        return self.playQueue[self.current];
    }
    return nil;
}

-(NSObject *)getItemAtIndex:(NSInteger)index {
    if (index < [self.playQueue count] && index > -1) {
        return self.playQueue[index];
    }
    return nil;
}

-(NSObject *)getItemAtIndexAndSetAsCurrent:(NSInteger)index {
    if (index < [self.playQueue count] && index > -1) {
        self.current = (int)index;
        return self.playQueue[self.current];
    }
    return nil;
}

-(NSString *)getTitleAtIndex:(NSInteger)index {
    if ([self itemAtIndexIsMP: index]) {
        return ((MPMediaItem *)self.playQueue[index]).title;
    } else {
        return ((SPTPartialTrack *)self.playQueue[index]).name;
    }
    return nil;
}

-(NSString *)getArtistAtIndex:(NSInteger)index {
    if ([self itemAtIndexIsMP: index]) {
        return ((MPMediaItem *)self.playQueue[index]).artist;
    } else {
        return [((SPTPartialTrack *)self.playQueue[index]).artists componentsJoinedByString:@","];
    }
}

-(NSString *)getAlbumAtIndex:(NSInteger)index {
    if ([self itemAtIndexIsMP: index]) {
        return ((MPMediaItem *)self.playQueue[index]).albumTitle;
    } else {
        return ((SPTPartialTrack *)self.playQueue[index]).album.name;
    }
}


@end
