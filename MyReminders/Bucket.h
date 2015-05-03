//
//  Bucket.h
//  MyReminders
//
//  Created by Josh Nagel on 5/2/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bucket : NSObject

@property(strong,nonatomic)Bucket *next;
@property(strong,nonatomic)NSString *key;
@property(strong,nonatomic)id data;

@end
