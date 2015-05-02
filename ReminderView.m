//
//  ReminderView.m
//  MyReminders
//
//  Created by Josh Nagel on 5/1/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ReminderView.h"
#import "MyReminderStyleKit.h"

@implementation ReminderView

- (void)drawRect:(CGRect)rect {
  [MyReminderStyleKit drawRedGradientBarWithFrame:rect];
}

@end
