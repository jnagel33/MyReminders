//
//  RemindersTableViewController.m
//  MyReminders
//
//  Created by Josh Nagel on 4/28/15.
//  Copyright (c) 2015 jnagel. All rights reserved.
//

#import "RemindersTableViewController.h"

const int kNameIndexPath = 0;
const int kDescriptionIndePath = 1;

@interface RemindersTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@end

@implementation RemindersTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.nameTextField.text = [self.currentAnnotation.annotation title];
  self.descriptionTextField.text = [self.currentAnnotation.annotation subtitle];
  CLLocationCoordinate2D coordinate = [self.currentAnnotation.annotation coordinate];
  self.latitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.latitude];
  self.longitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.longitude];
}
- (IBAction)donePressed:(UIBarButtonItem *)sender {
  [self.delegate name:self.nameTextField.text AndOrDescriptionModified:self.descriptionTextField.text];
  [self.navigationController popViewControllerAnimated:true];
}

//MARK:
//MARK: UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == kNameIndexPath) {
    [self.nameTextField becomeFirstResponder];
  } else if (indexPath.row == kDescriptionIndePath) {
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
