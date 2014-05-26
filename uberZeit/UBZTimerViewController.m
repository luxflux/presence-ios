//
//  ViewController.m
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZTimerViewController.h"
#import "UBZTimer.h"
#import "UBZUberZeitAPI.h"
#import "UYLPasswordManager.h"


@interface UBZTimerViewController ()
@property (nonatomic) UBZTimer *timer;

@property (nonatomic, strong) IBOutlet UILabel *topText;
@property (nonatomic, strong) IBOutlet UIButton *startStopButton;

@property (nonatomic, strong) NSString *api_url;
@property (nonatomic, strong) NSString *api_key;
@property (nonatomic, weak) UYLPasswordManager *keychain;
@property (nonatomic, strong) UBZUberZeitAPI *uberzeit_api;

@end

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
    //[self loadCurrentTimer];
    
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
    self.timer = timer;
    [self handleTimerUpdate];
}


- (IBAction)startStopButtonPressed {
    if(self.timer.running) {
        NSLog(@"Stopping timer");
        [self.uberzeit_api stopTimer];
    } else {
        NSLog(@"Starting timer");
    }
}



- (void)handleTimerUpdate {
    if(self.timer.running) {
        NSLog(@"Timer is running");
        [self updateDuration];
    } else {
        NSLog(@"Time is not running");
        [self updateDuration];
    }
}

- (void)updateDuration {
    [self presentText:self.timer.duration];
}

- (void)reloadPreferences {
    if(!self.keychain) {
        self.keychain = [UYLPasswordManager sharedInstance];
    }
    self.api_url = [self.keychain keyForIdentifier:@"api_url"];
    self.api_key = [self.keychain keyForIdentifier:@"api_key"];
    
    NSLog(@"controller: setting api_url to %@", self.api_url);
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

- (void)presentText:(NSString *)text {
    self.topText.numberOfLines = 0;
    self.topText.textColor = [UIColor blackColor];
    self.topText.text = text;
    self.topText.hidden = false;
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
