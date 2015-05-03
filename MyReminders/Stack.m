//
//  Stack.m
//  MyReminders
//
//  Created by Josh Nagel on 4/27/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "Stack.h"

@interface Stack()

@property (strong, nonatomic) NSMutableArray *stackArray;

@end

@implementation Stack

-(void)removeFromStack {
  if (!self.stackArray || !self.stackArray.count)
  [self.stackArray removeLastObject];
}

-(void)addToStack: (NSString *)newString {
  [self.stackArray addObject:newString];
}

-(NSString *)peak {
  return [self.stackArray lastObject];
}

@end
