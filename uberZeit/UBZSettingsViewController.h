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

@property (nonatomic, weak) IBOutlet UITextField *apiURLField;
@property (nonatomic, weak) IBOutlet UITextField *apiKeyField;
@property (nonatomic, weak) UYLPasswordManager *keychain;

@end
