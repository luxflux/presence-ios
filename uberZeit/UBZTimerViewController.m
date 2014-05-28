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
    
    self.time_types = @[@"Schaffe", @"Penne"];
    self.time_type_ids = @[@1, @2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.time_types.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.time_types[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Selected %i", row);
    self.selected_time_type_id = self.time_type_ids[row];
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
}


- (void)timerStoppingFailed:(NSString *)error {
    [self presentErrorText:error];
    self.startStopButton.hidden = true;
}

- (void)timerStoppingCompleted:(UBZTimer *)timer {
    [self presentSuccessText:@"Timer stopped successfully!"];

    [self performSelector:@selector(loadCurrentTimer) withObject:NULL afterDelay:3.0];
    [self performSelector:@selector(resetText) withObject:NULL afterDelay:3.0];

    self.timer = timer;
    [self handleTimerUpdate];
}


- (void)timerStartingFailed:(NSString *)error {
    [self presentErrorText:error];
    self.startStopButton.hidden = true;
}

- (void)timerStartingCompleted:(UBZTimer *)timer {
    [self presentSuccessText:@"Timer started successfully!"];
    
    [self performSelector:@selector(loadCurrentTimer) withObject:NULL afterDelay:3.0];
    [self performSelector:@selector(resetText) withObject:NULL afterDelay:3.0];
    
    self.timer = timer;
    [self handleTimerUpdate];
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
    self.durationLabel.text = self.timer.duration;
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
