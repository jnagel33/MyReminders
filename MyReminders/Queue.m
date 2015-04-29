//
//  Queue.m
//  MyReminders
//
//  Created by Josh Nagel on 4/27/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "Queue.h"

@interface Queue()

@property (strong, nonatomic) NSMutableArray *queueArray;

@end

@implementation Queue

-(void)removeFromQueue {
  if (!self.queueArray || !self.queueArray.count) {
    [self.queueArray removeObjectAtIndex:0];
  }
}

-(void)addToQueue: (NSString *)newString {
  [self.queueArray addObject:newString];
}

@end
