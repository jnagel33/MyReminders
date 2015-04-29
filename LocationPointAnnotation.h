//
//  LocationPointAnnotation.h
//  MyReminders
//
//  Created by Josh Nagel on 4/29/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface LocationPointAnnotation : MKPointAnnotation

@property(assign,nonatomic) BOOL reminderOn;
@property(strong,nonatomic) NSString *reminder;

@end
