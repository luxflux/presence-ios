//
//  ViewController.m
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZTimerViewController.h"

@implementation UBZTimerViewController

@synthesize timer = _timer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [self reloadPreferences];
    [self handlePreferences];
    
    self.uberzeit_api = [[UBZUberZeitAPI alloc] initWithCallbackObject:self withApiURL:self.api_url withApiKey:self.api_key];
    
    [self loadTimeTypes];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(loadCurrentTimer)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)loadCurrentTimer {
    
    if([self.api_url length ] == 0 || [self.api_key length ] == 0) {
        return;
    }
    
    [self.uberzeit_api loadTimer];
}

- (void)timerLoadingFailed:(NSString *)error {
    [self presentErrorText:error];
    self.startStopButton.hidden = true;
}

- (void)timerLoadingCompleted:(UBZTimer *)timer {
    self.timer = timer;
    [self handleTimerUpdate];
    self.startStopButton.hidden = false;
    [self resetText];
}


- (void)timerStoppingFailed:(NSString *)error {
    [self loadCurrentTimer];
}

- (void)timerStoppingCompleted:(UBZTimer *)timer {
    self.timer = timer;
    [self handleTimerUpdate];
}


- (void)timerStartingFailed:(NSString *)error {
    [self loadCurrentTimer];
}

- (void)timerStartingCompleted:(UBZTimer *)timer {
    self.timer = timer;
    [self handleTimerUpdate];
    [self loadCurrentTimerInAfewSeconds];
}


- (void)timeTypeLoadingFailed:(NSString *)error {
    [self presentErrorText:error];
    self.startStopButton.hidden = true;
}
- (void)timeTypeLoadingCompleted:(NSArray *)time_types {
    for (NSDictionary *time_type in time_types) {
        if([[time_type valueForKey:@"is_work"] intValue] == 1) {
            self.selected_time_type_id = [[time_type valueForKey:@"id"] intValue];
            break;
        }
    }
}

- (IBAction)startStopButtonPressed {
    if(self.timer.running) {
        NSLog(@"Stopping timer");
        [self.uberzeit_api stopTimer];
    } else {
        NSLog(@"Starting timer");
        [self.uberzeit_api startTimer];
    }
}

- (void)loadTimeTypes {
    if([self.api_url length ] == 0 || [self.api_key length ] == 0) {
        return;
    }
    
    [self.uberzeit_api loadTimeTypes];
}



- (void)handleTimerUpdate {
    if(self.timer.running) {
        NSLog(@"Timer is running");
        [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self updateDuration];
    } else {
        NSLog(@"Timer is not running");
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
        [self updateDuration];
    }
}

- (void)updateDuration {
    if(self.timer.running) {
        self.durationLabel.text = self.timer.duration;
    } else {
        self.durationLabel.text = @"--:--";
    }
}

- (void)reloadPreferences {
    if(!self.keychain) {
        self.keychain = [UYLPasswordManager sharedInstance];
    }
    self.api_url = [self.keychain keyForIdentifier:@"api_url"];
    self.api_key = [self.keychain keyForIdentifier:@"api_key"];
    
    [self.uberzeit_api updateApiURL:self.api_url];
    [self.uberzeit_api updateApiKey:self.api_key];
}


- (void)handlePreferences {
    NSString *error = [self errorFromPreferences];
    if(error) {
        [self presentErrorText:error];
        self.startStopButton.hidden = false;
    } else {
        self.topText.hidden = true;
        self.startStopButton.hidden = false;
    }
}

- (void)presentErrorText:(NSString *)text {
    [self presentText:text];
    self.topText.textColor = [UIColor redColor];
}

- (void)presentSuccessText:(NSString *)text {
    [self presentText:text];
    self.topText.textColor = [UIColor greenColor];
    [self resetTextInAfewSeconds];
}

- (void)presentText:(NSString *)text {
    self.topText.numberOfLines = 0;
    self.topText.textColor = [UIColor blackColor];
    self.topText.text = text;
    self.topText.hidden = false;
}

- (void)resetText {
    self.topText.hidden = true;
}

- (void)loadCurrentTimerInAfewSeconds {
    [self performSelector:@selector(loadCurrentTimer) withObject:NULL afterDelay:3.0];
}

- (void)resetTextInAfewSeconds {
    [self performSelector:@selector(resetText) withObject:NULL afterDelay:3.0];
}


- (NSString *)errorFromPreferences {
    if([self.api_url length ] == 0 || [self.api_key length ] == 0) {
        return @"No API endpoint or key specified. Please configure them in your settings.";
    } else {
        return Nil;
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self reloadPreferences];
    [self handlePreferences];
    [self loadCurrentTimer];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadPreferences];
    [self handlePreferences];
    [self loadCurrentTimer];
}

@end
