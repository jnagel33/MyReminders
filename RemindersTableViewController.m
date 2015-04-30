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
const int kDescriptionIndexPath = 1;

@interface RemindersTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UITextField *reminderTextField;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;

@end

@implementation RemindersTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.nameTextField.text = self.currentAnnotation.title;
  self.descriptionTextField.text = self.currentAnnotation.subtitle;
  CLLocationCoordinate2D coordinate = self.currentAnnotation.coordinate;
  self.latitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.latitude];
  self.longitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.longitude];
  self.reminderSwitch.on = self.currentAnnotation.reminderOn;
  self.reminderTextField.text = self.currentAnnotation.reminder;
}
- (IBAction)donePressed:(UIBarButtonItem *)sender {
  self.currentAnnotation.title = self.nameTextField.text;
  self.currentAnnotation.subtitle = self.descriptionTextField.text;
  self.currentAnnotation.reminder = self.reminderTextField.text;
  self.currentAnnotation.reminderOn = self.reminderSwitch.on;
  
  NSDictionary *userInfo = @{@"annotation": self.currentAnnotation};
  [[NSNotificationCenter defaultCenter]postNotificationName:@"pointAnnotationChanged" object:self userInfo:userInfo];
  [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)toggleReminderSwitched:(UISwitch *)sender {
  self.reminderSwitch.on = sender.on;
}

//MARK:
//MARK: UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == kNameIndexPath) {
    [self.nameTextField becomeFirstResponder];
  } else if (indexPath.row == kDescriptionIndexPath) {
    [self.descriptionTextField becomeFirstResponder];
  }
}

//MARK:
//MARK: UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.nameTextField) {
    [self.descriptionTextField becomeFirstResponder];
  }
  return true;
}

@end
