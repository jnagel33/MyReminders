//
//  RegionInterfaceController.m
//  MyReminders
//
//  Created by Josh Nagel on 4/30/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "RegionInterfaceController.h"
#import <CoreLocation/CoreLocation.h>

@interface RegionInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceMap *map;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *regionLabel;

@end

@implementation RegionInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    CLCircularRegion *region = context;
  [self.regionLabel setText:region.identifier];
  MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.005, 0.005);
  
  [self.map setRegion:MKCoordinateRegionMake(region.center, coordinateSpan)];
  [self.map addAnnotation:region.center withPinColor:WKInterfaceMapPinColorPurple];
  
  
  
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



