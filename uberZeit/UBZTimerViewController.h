//
//  ViewController.h
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBZTimer.h"
#import "UBZUberZeitAPI.h"
#import "UYLPasswordManager.h"


@interface UBZTimerViewController : UIViewController

@property (nonatomic) UBZTimer *timer;

@property (nonatomic, strong) IBOutlet UILabel *topText;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) IBOutlet UIButton *startStopButton;

@property (nonatomic, strong) NSString *api_url;
@property (nonatomic, strong) NSString *api_key;
@property (nonatomic, weak) UYLPasswordManager *keychain;
@property (nonatomic, strong) UBZUberZeitAPI *uberzeit_api;

@property (nonatomic) int selected_time_type_id;

- (IBAction)startStopButtonPressed;

- (void)timerLoadingFailed:(NSString *)error;
- (void)timerLoadingCompleted:(UBZTimer *)timer;

- (void)timerStoppingFailed:(NSString *)error;
- (void)timerStoppingCompleted:(UBZTimer *)timer;

- (void)timerStartingFailed:(NSString *)error;
- (void)timerStartingCompleted:(UBZTimer *)timer;

- (void)timeTypeLoadingFailed:(NSString *)error;
- (void)timeTypeLoadingCompleted:(NSArray *)time_types;

@end