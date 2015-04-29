//
//  Location.h
//  MyReminders
//
//  Created by Josh Nagel on 4/28/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject <MKAnnotation>

@property (nonatomic,readwrite,assign) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;

-(instancetype)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;
-(MKPinAnnotationView *)annotationView;

@end
