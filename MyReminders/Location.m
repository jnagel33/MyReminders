//
//  Location.m
//  MyReminders
//
//  Created by Josh Nagel on 4/28/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "Location.h"

@implementation Location

-(instancetype)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location {
  self = [super init];
  if (self) {
    _title = newTitle;
    _coordinate = location;
  }
  
  return self;
}

-(MKPinAnnotationView *)annotationView {
  MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"Location"];
  pinAnnotationView.enabled = true;
  pinAnnotationView.pinColor = MKPinAnnotationColorPurple;
  pinAnnotationView.canShowCallout = true;
  pinAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
  
  return pinAnnotationView;
}

@end
