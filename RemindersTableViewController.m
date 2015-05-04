//
//  RemindersTableViewController.m
//  MyReminders
//
//  Created by Josh Nagel on 4/28/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "RemindersTableViewController.h"
#import "LocationPointAnnotation.h"

const int kNameIndexPath = 0;
const int kReminderIndexPath = 1;
const CGFloat kReminderTitleRectHeight = 40;
const CGFloat kReminderTitleRectWidth = 80;
const CGFloat kReminderTitleFontSize = 20;
const NSString *placeholderLocationName = @"New";

@interface RemindersTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UITextField *reminderTextField;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *mapSnapShot;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation RemindersTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.activityIndicator startAnimating];
  [self.slider setThumbImage:[UIImage imageNamed:@"ThumbButton"] forState:UIControlStateNormal];
  [self.slider setThumbImage:[UIImage imageNamed:@"ThumbButton"] forState:UIControlStateHighlighted];
  [self.slider setMinimumTrackImage:[UIImage imageNamed:@"MinValSlider"] forState:UIControlStateNormal];
  [self.slider setMinimumTrackImage:[UIImage imageNamed:@"MinValSlider"] forState:UIControlStateSelected];
  [self.slider setMaximumTrackImage:[UIImage imageNamed:@"MaxValSlider"] forState:UIControlStateNormal];
  [self.slider setMaximumTrackImage:[UIImage imageNamed:@"MaxValSlider"] forState:UIControlStateSelected];
  self.slider.value = self.currentAnnotation.radius;
  
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentAnnotation.coordinate, 50, 50);
  MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
  options.region = region;
  options.scale = [UIScreen mainScreen].scale;
  options.size = self.mapSnapShot.frame.size;
  options.mapType = MKMapTypeSatellite;
  
  MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
  [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
    UIImage *image = snapshot.image;
    UIGraphicsBeginImageContext(self.mapSnapShot.frame.size);
    [image drawInRect:CGRectMake(0, 0, self.mapSnapShot.frame.size.width, self.mapSnapShot.frame.size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.activityIndicator stopAnimating];
    self.mapSnapShot.image = resizedImage;
  }];

  UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kReminderTitleRectWidth, kReminderTitleRectHeight)];
  titleLabel.text = @"Reminder";
  titleLabel.font = [UIFont fontWithName:@"Optima" size:kReminderTitleFontSize];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  self.navigationItem.titleView = titleLabel;
  
  self.nameTextField.delegate = self;
  self.reminderTextField.delegate = self;
  
  if (self.currentAnnotation.title != placeholderLocationName) {
    self.nameTextField.text = self.currentAnnotation.title;
  } else {
    self.doneButton.enabled = false;
    self.nameTextField.text = nil;
    self.nameTextField.placeholder = @"Enter location name";
  }
  
  CLLocationCoordinate2D coordinate = self.currentAnnotation.coordinate;
  self.latitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.latitude];
  self.longitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.longitude];
  self.reminderSwitch.on = self.currentAnnotation.reminderOn;
  self.reminderTextField.text = self.currentAnnotation.reminder;
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
  self.currentAnnotation.title = self.nameTextField.text;
  self.currentAnnotation.reminder = self.reminderTextField.text;
  self.currentAnnotation.reminderOn = self.reminderSwitch.on;
  
  NSDictionary *userInfo = @{@"annotation": self.currentAnnotation};
  [[NSNotificationCenter defaultCenter]postNotificationName:@"pointAnnotationChanged" object:self userInfo:userInfo];
  [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)toggleReminderSwitched:(UISwitch *)sender {
  self.reminderSwitch.on = sender.on;
  if (!self.reminderTextField.text.length > 0) {
    self.doneButton.enabled = false;
  }
}

//MARK:
//MARK: UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == kNameIndexPath) {
    [self.nameTextField becomeFirstResponder];
  } else if (indexPath.row == kReminderIndexPath) {
    [self.reminderTextField becomeFirstResponder];
  }
}

//MARK:
//MARK: UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.nameTextField) {
    [self.reminderTextField becomeFirstResponder];
  } else {
    [textField resignFirstResponder];
  }
  return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (textField == self.nameTextField) {
    if (string.length > 0) {
      self.doneButton.enabled = true;
    } else {
      if (textField.text.length <= 1) {
        self.doneButton.enabled = false;
      }
    }
  } else if (textField == self.reminderTextField) {
    if (self.reminderSwitch.on) {
      if (string.length > 0) {
        self.doneButton.enabled = true;
      } else {
        if (textField.text.length <= 1) {
          self.doneButton.enabled = false;
        }
      }
    }
  }
  return true;
}
- (IBAction)sliderValueChanged:(UISlider *)sender {
  self.currentAnnotation.radius = sender.value;
}

@end
