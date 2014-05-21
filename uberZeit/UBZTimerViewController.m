//
//  ViewController.m
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZTimerViewController.h"
#import "Timer.h"


@interface UBZTimerViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) NSInteger responseCode;
@property (nonatomic) Timer *timer;
@end

@implementation UBZTimerViewController

@synthesize responseData = _responseData;
@synthesize responseCode = _responseCode;
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
    
    NSString *timer_url = [NSString stringWithFormat:@"%@/api/timer", api_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:timer_url]];
    
    // Create a mutable copy of the immutable request and add more headers
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setValue:api_key forHTTPHeaderField:@"X-Auth-Token"];
    
    // Now set our request variable with an (immutable) copy of the altered request
    request = [mutableRequest copy];
    
    NSLog(@"%@", request.allHTTPHeaderFields);
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    NSLog(@"didReceiveResponse");
    self.responseData = [[NSMutableData alloc] init];
    [self.responseData setLength:0];
    self.responseCode = response.statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    NSLog(@"Received data %d",[data length]);
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    switch(self.responseCode) {
        case 200: { // Timer running
            
            // convert to JSON
            NSError *myError = nil;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
            
            NSDateFormatter *uberZeitDateFormatter = [[NSDateFormatter alloc] init];
            [uberZeitDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            
            NSString *start = [NSString stringWithFormat:@"%@ %@", [res objectForKey:@"date"], [res objectForKey:@"start"]];
            
            self.timer = [[Timer alloc] init];
            self.timer.time_type_id = [res objectForKey:@"time_type_id"];
            self.timer.start = [uberZeitDateFormatter dateFromString:start];
            self.timer.end = [res objectForKey:@"end"];
            self.timer.duration = [res objectForKey:@"duration"];
            
            if([self.timer.end isKindOfClass:[NSNull class]]) {
                self.timer.running = YES;
            } else {
                NSLog(@"Time not running...? %@", self.timer.end);
                self.timer.running = NO;
            }
            
            [self handleTimerUpdate];
            break;
        }
        case 401: { // API Token wrong?
            break;
        }
        case 404: { // No Timer running
            self.timer = [[Timer alloc] init];
            self.timer.duration = @"00:00";
            self.timer.running = NO;
            
            [self handleTimerUpdate];
            break;
        }
        case 422: {
            NSError *myError = nil;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
            
            NSLog(@"%@", [res objectForKey:@"errors"]);
        }
        default: {
            NSLog(@"%d", self.responseCode);
        }
    }
    
}

- (IBAction)startStopButtonPressed {
    NSLog(@"Button pressed");
    if(self.timer.running) {
        NSLog(@"Stopping timer");
        [self stopTimer];
    } else {
        NSLog(@"Starting timer");
    }
}

- (void)stopTimer {
    NSString *timer_url = [NSString stringWithFormat:@"%@/api/timer", api_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:timer_url]];
    
    [request setValue:api_key forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // Specify that it will be a POST request
    request.HTTPMethod = @"PUT";
    
    // Convert your data and set your request's HTTPBody property
    NSMutableDictionary *timerDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [timerDictionary setObject:@"now" forKey:@"end"];
    
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:timerDictionary options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
    
    if(!jsonSerializationError) {
        NSString *serJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Serialized JSON: %@", serJSON);
    } else {
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
    topText.text = self.timer.duration;
    topText.hidden = false;
}

- (void)reloadPreferences {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    api_url = [standardUserDefaults objectForKey:@"api_url_preference"];
    api_key = [standardUserDefaults objectForKey:@"api_key_preference"];
    NSLog(@"URL: %@", api_url);
    NSLog(@"Key: %@", api_key);
}


- (void)handlePreferences {
    if([api_url length ] == 0 || [api_key length ] == 0) {
        topText.text = @"No API endpoint or key specified. Please configure them via system settings.";
        topText.hidden = false;
        startStopButton.hidden = true;
    } else {
        topText.hidden = true;
        startStopButton.hidden = false;
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self reloadPreferences];
    [self handlePreferences];
}


@end
