//
//  ReminderButton.m
//  MyReminders
//
//  Created by Josh Nagel on 5/2/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "ReminderButton.h"
#import "MyReminderStyleKit.h"

@implementation ReminderButton

- (void)drawRect:(CGRect)rect {
   [MyReminderStyleKit drawRedGradientBarWithFrame:rect];
}


@end
