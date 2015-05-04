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
#import "AppDelegate.h"
#import "RemindersTableViewController.h"
#import "MyReminderStyleKit.h"
#import "ReminderButton.h"

struct Coordinate {
  CGFloat latitude;
  CGFloat longitude;
};
const CGFloat kTitleRectHeight = 40;
const CGFloat kTitleRectWidth = 80;
const CGFloat kTitleFontSize = 20;
const CGFloat kSetRegionBuffer = 1000;
const CGFloat kPointAnnotationDefaultRadius = 300;
const CGFloat kReminderViewBottomConstraintOnScreen = 50;
const CGFloat kReminderViewBottomConstraintOffScreen = -125;
const CGFloat kCircleRenderOverlayAlpha = 0.3;
const CGFloat kAlertIconHeightWidth = 25;
const CGFloat kNavBarPlusStatusBarHeight = 64;
const CGFloat kCustomTransformY = 0.8;
const double kAnimationDuration = 1;
const double kAnimationDurationQuick = 0.1;
const double kAnimationDurationHalfSecond = 0.5;
const double kDelayBetweenDrops = 0.05;
static const struct Coordinate kSeattleCoordinates = {47.6097, -122.3331};
static const struct Coordinate kSaltLakeCityCoordinates = {40.75, -111.8833};
static const struct Coordinate kAustinCoordinates = {30.25, -97.7500};

@interface HomeMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) LocationPointAnnotation *currentAnnotation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintReminderViewBottom;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;

@end

@implementation HomeMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIImage *navBar = [MyReminderStyleKit imageOfRedGradientBarWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kNavBarPlusStatusBarHeight)];
  [self.navigationController.navigationBar setBackgroundImage:navBar forBarMetrics:UIBarMetricsDefault];
  UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kTitleRectWidth, kTitleRectHeight)];
  titleLabel.font = [UIFont fontWithName:@"Optima" size:kTitleFontSize];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.text = @"My Reminders";
  self.navigationItem.titleView = titleLabel;
  
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pointAnnotationChanged:) name:@"pointAnnotationChanged" object:nil];
  
  [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationForRegion:) name:@"notificationForRegion" object:nil];
  
  self.mapView.delegate = self;
  self.locationManager = [[CLLocationManager alloc]init];
  self.locationManager.delegate = self;
  self.mapView.mapType = MKMapTypeSatellite;
  if ([CLLocationManager locationServicesEnabled]) {
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if (authStatus == kCLAuthorizationStatusNotDetermined) {
      [self.locationManager requestAlwaysAuthorization];
    } else if (authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted) {
      [self showLocationServicesAlert];
    } else {
      NSArray *regions = self.locationManager.monitoredRegions.allObjects;
      for (CLCircularRegion *region in regions) {
        LocationPointAnnotation *annotation = [[LocationPointAnnotation alloc]init];
        annotation.coordinate = region.center;
        annotation.title = region.identifier;
        annotation.reminder = region.identifier;
        annotation.reminderOn = true;
        [self.mapView addAnnotation: annotation];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
        [self.mapView addOverlay:circle];
      }
      if (self.notificationRegion != nil) {
        [self setLocationRegion:self.notificationRegion.center];
      }
    }
  }
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
  [self.mapView addGestureRecognizer:longPress];
}

- (void)viewWillAppear {
  self.navigationController.navigationBar.hidden = YES;
}

-(void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)longPress: (UILongPressGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    CGPoint pointPressed = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:pointPressed toCoordinateFromView:self.mapView];
    LocationPointAnnotation *pointAnnotation = [[LocationPointAnnotation alloc]init];
    pointAnnotation.title = @"New";
    pointAnnotation.subtitle = nil;
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.reminderOn = false;
    pointAnnotation.reminder = nil;
    pointAnnotation.radius = kPointAnnotationDefaultRadius;
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
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, kSetRegionBuffer, kSetRegionBuffer);
  MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
  [self.mapView setRegion:adjustedRegion animated:true];
}

- (IBAction)seattleButtonPressed:(UIButton *)sender {
  CLLocationCoordinate2D seattleCoordinate = CLLocationCoordinate2DMake(kSeattleCoordinates.latitude, kSeattleCoordinates.longitude);
  [self setLocationRegion:seattleCoordinate];
}
- (IBAction)saltLakeCityButtonPressed:(UIButton *)sender {
  CLLocationCoordinate2D saltLakeCoordinate = CLLocationCoordinate2DMake(kSaltLakeCityCoordinates.latitude, kSaltLakeCityCoordinates.longitude);
  [self setLocationRegion:saltLakeCoordinate];
}
- (IBAction)austinButtonPressed:(UIButton *)sender {
  [self.locationManager stopUpdatingLocation];
  CLLocationCoordinate2D austinCoordinate = CLLocationCoordinate2DMake(kAustinCoordinates.latitude, kAustinCoordinates.longitude);
  [self setLocationRegion:austinCoordinate];
}

-(void)startMonitoringAndAddOverlayForRegion: (CLCircularRegion *)region {
  [self.locationManager startMonitoringForRegion:region];
  MKCircle *circle = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
  [self.mapView addOverlay:circle];
}

-(void)stopMonitoringAndRemoveOverlay:(CLCircularRegion *)region {
  [self.locationManager stopMonitoringForRegion:region];
  NSArray *overlays = [self.mapView overlays];
  for (MKCircle *overlay in overlays) {
    if (overlay.coordinate.latitude == region.center.latitude && overlay.coordinate.longitude == region.center.longitude) {
      [self.mapView removeOverlay:overlay];
    }
  }
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
  }
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
  NSLog(@"entered Region!");
  UILocalNotification *notification = [[UILocalNotification alloc] init];
  notification.alertTitle = @"New Reminder";
  notification.alertBody = region.identifier;
  notification.alertAction = @"EnteredRegion";
  NSDictionary *userInfo = @{ @"region" : region.identifier };
  notification.userInfo = userInfo;
  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
  NSLog(@"Left region");
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
  NSLog(@"Started monitoring");
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
  NSLog(@"Failed");
}

//MARK:
//MARK: MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Location"];
  LocationPointAnnotation *pointAnnotation = (LocationPointAnnotation *)annotation;
  if (annotationView == nil) {
    annotationView = [[MKAnnotationView alloc]initWithAnnotation:pointAnnotation reuseIdentifier:@"Location"];
    annotationView.enabled = true;
    annotationView.draggable = true;
    [annotationView setImage:[UIImage imageNamed:@"CustomPin"]];
    annotationView.canShowCallout = true;
    UIButton *detailDisclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    detailDisclosureButton.tintColor = [UIColor blackColor];
    annotationView.rightCalloutAccessoryView = detailDisclosureButton;
  }
  if (pointAnnotation.reminderOn) {
    UIButton *alertButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kAlertIconHeightWidth, kAlertIconHeightWidth)];
    UIImage *image = [UIImage imageNamed:@"AlarmIcon"];
    [alertButton setImage:image forState:UIControlStateNormal];
    annotationView.leftCalloutAccessoryView = alertButton;
  } else {
    annotationView.leftCalloutAccessoryView = nil;
  }
  [annotationView setCenterOffset:CGPointMake(0, -annotationView.frame.size.height / 2)];
  return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
  for (MKAnnotationView *annotationView in views) {
    if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) {
      continue;
    }
    
    MKMapPoint point =  MKMapPointForCoordinate(annotationView.annotation.coordinate);
    if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
      continue;
    }
    
    CGRect endFrame = annotationView.frame;
    annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y - self.view.frame.size.height, annotationView.frame.size.width, annotationView.frame.size.height);
    [UIView animateWithDuration:kAnimationDurationHalfSecond delay:kDelayBetweenDrops*[views indexOfObject:annotationView] options:UIViewAnimationOptionCurveEaseInOut animations:^{
      annotationView.frame = endFrame;
    }completion:^(BOOL finished){
      if (finished) {
        [UIView animateWithDuration:kAnimationDurationQuick animations:^{
          annotationView.transform = CGAffineTransformMakeScale(1.0, kCustomTransformY);
          
        }completion:^(BOOL finished){
          [UIView animateWithDuration:kAnimationDurationQuick animations:^{
            annotationView.transform = CGAffineTransformIdentity;
          }];
        }];
      }
    }];
    
  }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  self.currentAnnotation = view.annotation;
  [self performSegueWithIdentifier:@"ShowReminder" sender:self];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
  LocationPointAnnotation *pointAnnotation = (LocationPointAnnotation *)view.annotation;
  CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:pointAnnotation.coordinate radius:pointAnnotation.radius identifier:pointAnnotation.reminder];
  CGPoint endPoint = CGPointMake(view.center.x,view.center.y - 20);
  if (newState == MKAnnotationViewDragStateStarting) {
    [UIView animateWithDuration:kAnimationDurationQuick animations:^{
      view.center = endPoint;
    }];
    if (pointAnnotation.reminderOn) {
      [self stopMonitoringAndRemoveOverlay:region];
    }
  } else if (newState == MKAnnotationViewDragStateEnding || newState ==MKAnnotationViewDragStateCanceling) {
    endPoint = CGPointMake(view.center.x, view.center.y);
    [UIView animateWithDuration:kAnimationDurationQuick animations:^{
      view.center = endPoint;
    }];
    if (pointAnnotation.reminderOn) {
      [self stopMonitoringAndRemoveOverlay:region];
      [self startMonitoringAndAddOverlayForRegion:region];
      view.dragState = MKAnnotationViewDragStateNone;
    }
  }
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
  circleRenderer.fillColor = [UIColor redColor];
  circleRenderer.alpha = kCircleRenderOverlayAlpha;
  
  return circleRenderer;
}

//MARK:
//MARK: NSNotifications

-(void)pointAnnotationChanged:(NSNotification *)notification {
  [self.mapView removeAnnotation:self.currentAnnotation];
  LocationPointAnnotation *annotation = notification.userInfo[@"annotation"];
  [self.mapView addAnnotation:annotation];
  if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:annotation.coordinate radius:annotation.radius identifier:annotation.reminder];
    if (annotation.reminderOn) {
      [self stopMonitoringAndRemoveOverlay:region];
      [self startMonitoringAndAddOverlayForRegion:region];
    } else {
      [self stopMonitoringAndRemoveOverlay:region];
    }
  }
}

-(void)notificationForRegion:(NSNotification *)notification {
  CLCircularRegion *notificationRegion = notification.userInfo[@"region"];
  [self setLocationRegion:notificationRegion.center];
  self.constraintReminderViewBottom.constant = kReminderViewBottomConstraintOnScreen;
  self.reminderLabel.text = notificationRegion.identifier;
  [UIView animateWithDuration:kAnimationDuration animations:^{
    [self.view layoutIfNeeded];
  }];
}

- (IBAction)okPressed:(ReminderButton *)sender {
  self.constraintReminderViewBottom.constant = kReminderViewBottomConstraintOffScreen;
  [UIView animateWithDuration:kAnimationDuration animations:^{
    [self.view layoutIfNeeded];
  }];
}

//MARK:
//MARK: Prepare for segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier  isEqual: @"ShowReminder"]) {
    RemindersTableViewController *destinationController = [segue destinationViewController];
    destinationController.currentAnnotation = self.currentAnnotation;
  }
}

@end
