//
//  RemindersTableViewController.h
//  MyReminders
//
//  Created by Josh Nagel on 4/28/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol RemindersTableViewDelegate

-(void)name:(NSString *)name AndOrDescriptionModified:(NSString *)description;

@end

@interface RemindersTableViewController : UITableViewController

@property(strong, nonatomic)MKAnnotationView *currentAnnotation;
@property (nonatomic, weak) id <RemindersTableViewDelegate> delegate;

@end