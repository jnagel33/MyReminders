//
//  HashTable.h
//  MyReminders
//
//  Created by Josh Nagel on 5/2/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HashTable : NSObject

-(instancetype)initWithSize:(NSInteger)size;
-(void)addObject:(id)object forKey:(NSString *)key;
-(void)removeObjectForKey:(NSString *)key;
-(id)objectForKey:(NSString *)key;

@end
