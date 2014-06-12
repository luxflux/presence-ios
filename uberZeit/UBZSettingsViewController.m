//
//  UBZSettings.m
//  uberZeit
//
//  Created by Raffael Schmid on 21.05.14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZSettingsViewController.h"

@implementation UBZSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.keychain = [UYLPasswordManager sharedInstance];
    
    self.apiURLField.text = [self.keychain keyForIdentifier:@"api_url"];
    self.apiKeyField.text = [self.keychain keyForIdentifier:@"api_key"];
    
    //[self loadTimeTypes];
    
    self.time_type_names = [[NSMutableArray alloc] initWithArray:@[@"Schaffe", @"Penne"]];
    self.time_type_ids = [[NSMutableArray alloc] initWithArray:@[@1,@2]];
    
    self.toggle = 0;
    self.pickerView = [[UIPickerView alloc] initWithFrame:(CGRect){{0, 0}, 320, 480}];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.center = (CGPoint){160, 640};
    self.pickerView.hidden = YES;
    [self.view addSubview:self.pickerView];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.time_type_names.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.time_type_names[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Selected %i", row);
    self.selected_time_type_id = self.time_type_ids[row];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *key;
    if(textField == self.apiURLField) {
        key = @"api_url";
    } else if (textField == self.apiKeyField) {
        key = @"api_key";
    } else {
        NSLog(@"w00t unknown field %@", textField);
    }
    
    if(key) {
        [self.keychain registerKey:textField.text forIdentifier:key];
        NSLog(@"Wrote %@ for %@", textField.text, key);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTimeTypes {
    
    if([self.apiURLField.text length ] == 0 || [self.apiKeyField.text length ] == 0) {
        return;
    }
    
    [self.uberzeit_api loadTimeTypes];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView beginUpdates];
    
    if (indexPath.section == 1 && indexPath.row == 0){
        self.toggle = 1;
        
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        [self.tableView insertRowsAtIndexPaths:@[indexPathToReveal] withRowAnimation:UITableViewRowAnimationFade];
        //UITableViewCell *currentCellSelected = [self.tableView cellForRowAtIndexPath:indexPath];
        //[UIView animateWithDuration:1.0f
        //                      delay:0.0f
        //                    options:UIViewAnimationOptionCurveEaseInOut
        //                 animations:^ {
        //                     self.pickerView.hidden = NO;
        //                     self.pickerView.center = (CGPoint){currentCellSelected.frame.size.width/2,
        //                         self.tableView.frame.origin.y + currentCellSelected.frame.size.height*6};
        //                 }
        //                 completion:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 1 && indexPath.row == 0 && self.toggle == 1 ? self.pickerView.frame.size.height : self.tableView.rowHeight);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return (self.toggle == 1 ? 2 : 1);
    } else {
        return 2;
    }
}

- (void)timeTypeLoadingFailed:(NSString *)error {
    
}
- (void)timeTypeLoadingCompleted:(NSArray *)time_types {
    [self.time_type_ids removeAllObjects];
    [self.time_type_names removeAllObjects];
    
    for (NSDictionary *time_type in time_types) {
        NSLog(@"%@", time_type);
        NSNumber *time_type_id = [time_type objectForKey:@"id"];
        NSString *time_type_name = [time_type objectForKey:@"name"];
        if(time_type_id && time_type_name) {
            [self.time_type_ids addObject:time_type_id];
            [self.time_type_names addObject:time_type_name];
        }
    }
    [self.timeTypePicker reloadAllComponents];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
