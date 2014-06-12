//
//  UBZSettings.h
//  uberZeit
//
//  Created by Raffael Schmid on 21.05.14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UYLPasswordManager.h"
#import "UBZUberZeitAPI.h"

@interface UBZSettingsViewController : UITableViewController
                                        <UIPickerViewDataSource, UIPickerViewDelegate>


@property (nonatomic, weak) IBOutlet UITextField *apiURLField;
@property (nonatomic, weak) IBOutlet UITextField *apiKeyField;
@property (nonatomic, weak) UYLPasswordManager *keychain;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *time_type_names;
@property (nonatomic, strong) NSMutableArray *time_type_ids;
@property (nonatomic, strong) NSNumber *selected_time_type_id;
@property (nonatomic, strong) UBZUberZeitAPI *uberzeit_api;

@property (nonatomic, strong) IBOutlet UIPickerView *timeTypePicker;
@property NSInteger toggle;

- (void)timeTypeLoadingFailed:(NSString *)error;
- (void)timeTypeLoadingCompleted:(NSArray *)time_types;

@end
