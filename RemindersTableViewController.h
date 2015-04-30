//
//  RemindersTableViewController.h
//  MyReminders
//
//  Created by Josh Nagel on 4/28/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LocationPointAnnotation;

@interface RemindersTableViewController : UITableViewController

@property(strong, nonatomic)LocationPointAnnotation *currentAnnotation;

@end
