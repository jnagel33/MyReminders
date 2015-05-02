//
//  HomeMapViewController.h
//  MyReminders
//
//  Created by Josh Nagel on 4/27/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class CLCircularRegion;

@interface HomeMapViewController : UIViewController

@property (strong, nonatomic)CLCircularRegion *notificationRegion;

@end

