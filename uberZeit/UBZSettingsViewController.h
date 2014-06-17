//
//  UBZSettings.h
//  uberZeit
//
//  Created by Raffael Schmid on 21.05.14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UYLPasswordManager.h"

@interface UBZSettingsViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UITextField *apiURLField;
@property (nonatomic, strong) IBOutlet UITextField *apiKeyField;
@property (nonatomic, strong) UYLPasswordManager *keychain;

@property (nonatomic, strong) IBOutlet UILabel *resultLabel;
@property (nonatomic, strong) IBOutlet UIButton *testSettingsButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *testSettingsActivityIndicator;

@property (nonatomic, strong) NSString *api_url;
@property (nonatomic, strong) NSString *api_key;


- (IBAction)testSettingsButtonPressed;

- (void)pingApiFailed:(NSString *)error;
- (void)pingApiCompleted;

@end
