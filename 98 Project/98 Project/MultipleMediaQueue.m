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
    return nil;
}

-(BOOL)nextIsSPT {
    if ([self hasNext]) {
        return [self itemAtIndexIsSPT:(self.current + 1)];
    }
    return nil;
}

-(BOOL)itemAtIndexIsMP:(int)index {
    if (index < [self.playQueue count] && index > -1) {
        NSObject *item = self.playQueue[index];
        return [item isKindOfClass: [MPMediaItem class]];
    }
    return nil;
}


//at the moment, spotify tracks are stored as their URI strings
-(BOOL)itemAtIndexIsSPT:(int)index {
    if (index < [self.playQueue count] && index > -1) {
        NSObject *item = self.playQueue[index];
        return [item isKindOfClass: [NSString class]];
    }
    return nil;
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

-(NSObject *)getItemAtIndex:(int)index {
    if (index < [self.playQueue count] && index > -1) {
        return self.playQueue[index];
    }
    return nil;
}

-(NSObject *)getItemAtIndexAndSetAsCurrent:(int)index {
    if (index < [self.playQueue count] && index > -1) {
        self.current = index;
        return self.playQueue[self.current];
    }
    return nil;
}

-(NSString *)getTitleAtIndex:(int)index {
    return nil;
}

-(NSString *)getArtistAtIndex:(int)index {
    return nil;
}

-(NSString *)getAlbumAtIndex:(int)index {
    return nil;
}


@end
