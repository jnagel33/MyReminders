//
//  InterfaceController.m
//  MyReminders WatchKit Extension
//
//  Created by Josh Nagel on 4/30/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "InterfaceController.h"
#import <CoreLocation/CoreLocation.h>
#import "RegionRow.h"


@interface InterfaceController()
@property(weak,nonatomic) IBOutlet WKInterfaceTable *table;
@property(strong,nonatomic) NSArray *regions;
@property(strong,nonatomic) CLLocationManager *locationManager;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
  [super awakeWithContext:context];
  self.locationManager = [[CLLocationManager alloc]init];
  self.regions = self.locationManager.monitoredRegions.allObjects;
  
  [self.table setNumberOfRows:self.regions.count withRowType:@"Region"];
  
  for (CLCircularRegion *region in self.regions) {
    NSUInteger index = [self.regions indexOfObject:region];
    RegionRow *row = [self.table rowControllerAtIndex:index];
    row.regionLabel.text = region.identifier;
  }
}

-(id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
  if ([segueIdentifier isEqualToString: @"ShowRegion"]) {
    return self.regions[rowIndex];
  } else {
    return nil;
  }
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



