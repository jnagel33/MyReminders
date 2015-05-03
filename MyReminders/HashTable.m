//
//  HashTable.m
//  MyReminders
//
//  Created by Josh Nagel on 5/2/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "HashTable.h"
#import "Bucket.h"

@interface HashTable()

@property(strong,nonatomic)NSMutableArray *items;
@property(nonatomic)NSUInteger count;
@property(nonatomic)NSUInteger size;

@end

@implementation HashTable

-(instancetype)initWithSize:(NSInteger)size {
  if (self = [super init]) {
    for (int i = 1; i < self.size; i++) {
      Bucket *bucket = [[Bucket alloc]init];
      [self.items addObject:bucket];
    }
    return self;
  }
  return nil;
}

-(void)addObject:(id)object forKey:(NSString *)key {
  NSInteger index = [self hash:key];
  Bucket *bucket = [self.items objectAtIndex:index];
  
  if (!bucket.key) {
    bucket.key = key;
    bucket.data = object;
  } else {
    Bucket *newBucket = [[Bucket alloc]init];
    newBucket.key = key;
    newBucket.data = object;
    newBucket.next = bucket;
    self.items[index] = newBucket;
  }
}

-(void)removeObjectForKey:(NSString *)key {
  NSInteger index = [self hash:key];
  Bucket *bucket = [self.items objectAtIndex:index];
  Bucket *previousBucket;
  
  while (bucket) {
    if ([bucket.key isEqualToString:key]) {
      if (!previousBucket) {
        if (!bucket.next) {
          bucket.key = nil;
          bucket.data = nil;
        } else {
          self.items[index] = bucket.next;
        }
      } else {
        previousBucket.next = bucket.next;
      }
    } else {
      previousBucket = bucket;
      bucket = bucket.next;
    }
  }
}

-(id)objectForKey:(NSString *)key {
  NSInteger index = [self hash:key];
  Bucket * bucket = [self.items objectAtIndex:index];
  while (bucket) {
    if (bucket.key == key) {
      return bucket.data;
    } else {
      bucket = bucket.next;
    }
  }
  return nil;
}

-(NSUInteger)hash: (NSString *)key {
  NSInteger total = 0;
  
  for (int i = 0; i < key.length; i++) {
    NSInteger ascii = [key characterAtIndex:i];
    total = total + ascii;
  }
  return total % self.size;
}

@end
