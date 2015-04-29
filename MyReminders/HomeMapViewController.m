//
//  ViewController.m
//  MyReminders
//
//  Created by Josh Nagel on 4/27/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "HomeMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationPointAnnotation.h"
#import "RemindersTableViewController.h"

@interface HomeMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, RemindersTableViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D location;
@property (strong, nonatomic) LocationPointAnnotation *currentAnnotation;

@end

@implementation HomeMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.mapView.delegate = self;
  self.locationManager.delegate = self;
  
  self.locationManager = [[CLLocationManager alloc]init];
  CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
  if (authStatus == kCLAuthorizationStatusNotDetermined) {
    [self.locationManager requestAlwaysAuthorization];
    return;
  } else if (authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted) {
    [self showLocationServicesAlert];
  } else {
    self.mapView.showsUserLocation = true;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  }
  
  
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
  [self.mapView addGestureRecognizer:longPress];
}

-(void)longPress: (UILongPressGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    CGPoint pointPressed = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:pointPressed toCoordinateFromView:self.mapView];
    LocationPointAnnotation *pointAnnotation = [[LocationPointAnnotation alloc]init];
    pointAnnotation.title = @"NewLocation";
    pointAnnotation.subtitle = @"More info";
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.reminderOn = false;
    pointAnnotation.reminder = @"test";
    [self.mapView addAnnotation: pointAnnotation];
  }
}

-(void)getCurrentLocation {
  self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  [self.locationManager startUpdatingLocation];
  self.mapView.mapType = MKMapTypeSatellite;
}

-(void)showLocationServicesAlert {
  UIAlertController *alertController = [UIAlertController
                                        alertControllerWithTitle:@"Location services disabled"
                                        message:@"Please enable location services for this app in settings"
                                        preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action)
                             {}];
  
  [alertController addAction:okAction];
  [self presentViewController:alertController animated:true completion:nil];
}

-(void)setLocationRegion: (CLLocationCoordinate2D)coordinate {
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
  MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
  [self.mapView setRegion:adjustedRegion animated:true];
}
- (IBAction)currentLocationPressed:(UIButton *)sender {
  [self getCurrentLocation];
}

- (IBAction)seattleButtonPressed:(UIButton *)sender {
  [self.locationManager stopUpdatingLocation];
  CLLocationCoordinate2D seattleCoordinate = CLLocationCoordinate2DMake(47.6097, -122.3331);
  [self setLocationRegion:seattleCoordinate];
}
- (IBAction)saltLakeCityButtonPressed:(UIButton *)sender {
  [self.locationManager stopUpdatingLocation];
  CLLocationCoordinate2D saltLakeCoordinate = CLLocationCoordinate2DMake(40.75, -111.8833);
  [self setLocationRegion:saltLakeCoordinate];
}
- (IBAction)austinButtonPressed:(UIButton *)sender {
  [self.locationManager stopUpdatingLocation];
  CLLocationCoordinate2D austinCoordinate = CLLocationCoordinate2DMake(30.25, -97.75);
  [self setLocationRegion:austinCoordinate];
}


//MARK:
//MARK: CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *newLocation = [locations lastObject];
  NSLog(@"%@", newLocation);
  CLLocationCoordinate2D newCoordinate = [newLocation coordinate];
  [self setLocationRegion:newCoordinate];
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  NSLog(@"%@", error.description);
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (status == kCLAuthorizationStatusAuthorizedAlways) {
    self.mapView.showsUserLocation = true;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  }
}

//MARK:
//MARK: MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Location"];
    if (annotationView == nil) {
      annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"Location"];
      annotationView.enabled = true;
      annotationView.draggable = true;
      annotationView.animatesDrop = true;
      annotationView.canShowCallout = true;
      annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
      
    }
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  self.currentAnnotation = view.annotation;
  [self performSegueWithIdentifier:@"ShowReminders" sender:self];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
  if (newState == MKAnnotationViewDragStateEnding) {
    [view.annotation coordinate];
  }
  
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier  isEqual: @"ShowReminders"]) {
    RemindersTableViewController *destinationController = [segue destinationViewController];
    destinationController.delegate = self;
    destinationController.currentAnnotation = self.currentAnnotation;
  }
}

//MARK RemindersTableViewDelegate

-(void)pointAnnotationChanged:(LocationPointAnnotation *)annotation {
  [self.mapView removeAnnotation:self.currentAnnotation];
  [self.mapView addAnnotation:annotation];
}

@end
