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

@property (nonatomic, weak) IBOutlet UILabel *topText;
@property (nonatomic, weak) IBOutlet UIButton *startStopButton;

@property (nonatomic, weak) NSString *api_url;
@property (nonatomic, weak) NSString *api_key;
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
    [self loadCurrentTimer];
    
    self.uberzeit_api = [[UBZUberZeitAPI alloc] initWithCallbackObject:self];

    
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
    
    [self.uberzeit_api loadCurrentTimer];
}

- (void)timerLoadingFailed:(NSString *)error {
    [self presentErrorText:error];
    self.startStopButton.hidden = true;
}

- (void)timerLoadingCompleted:(UBZTimer *)timer {
    self.timer = timer;
    [self handleTimerUpdate];
    
}

- (IBAction)startStopButtonPressed {
    if(self.timer.running) {
        NSLog(@"Stopping timer");
        [self stopTimer];
    } else {
        NSLog(@"Starting timer");
    }
}

- (void)stopTimer {
    NSString *timer_url = [NSString stringWithFormat:@"%@/api/timer", self.api_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:timer_url]];
    
    [request setValue:self.api_key forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // Specify that it will be a POST request
    request.HTTPMethod = @"PUT";
    
    // Convert your data and set your request's HTTPBody property
    NSMutableDictionary *timerDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [timerDictionary setObject:@"now" forKey:@"end"];
    
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:timerDictionary options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
    
    if(jsonSerializationError) {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [request setHTTPBody: jsonData];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    //[self presentErrorText:self.timer.duration asError:NO];
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
    self.topText.numberOfLines = 0;
    self.topText.textColor = [UIColor redColor];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadPreferences];
    [self handlePreferences];
    [self loadCurrentTimer];
}

@end
