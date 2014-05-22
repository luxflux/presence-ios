//
//  ViewController.m
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZTimerViewController.h"
#import "Timer.h"
#import "UYLPasswordManager.h"


@interface UBZTimerViewController ()
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) NSInteger responseCode;
@property (nonatomic) Timer *timer;

@property (nonatomic, weak) IBOutlet UILabel *topText;
@property (nonatomic, weak) IBOutlet UIButton *startStopButton;

@property (nonatomic, weak) NSString *api_url;
@property (nonatomic, weak) NSString *api_key;
@property (nonatomic, weak) UYLPasswordManager *keychain;

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
    
    if([self.api_url length ] == 0 || [self.api_key length ] == 0) {
        return;
    }
    
    NSString *timer_url = [NSString stringWithFormat:@"%@/api/timer", self.api_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:timer_url]];
    
    // Create a mutable copy of the immutable request and add more headers
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setValue:self.api_key forHTTPHeaderField:@"X-Auth-Token"];
    
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
    [self presentTopText:error.localizedDescription asError:true];
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
    self.topText.text = self.timer.duration;
    self.topText.hidden = false;
}

- (void)reloadPreferences {
    
    if(!self.keychain) {
        self.keychain = [UYLPasswordManager sharedInstance];
    }
    
    self.api_url = [self.keychain keyForIdentifier:@"api_url"];
    self.api_key = [self.keychain keyForIdentifier:@"api_key"];
}


- (void)handlePreferences {
    NSString *error = [self errorFromPreferences];
    if(error) {
        [self presentTopText:error asError:FALSE];
    } else {
        self.topText.hidden = true;
        self.startStopButton.hidden = false;
    }
}

- (void)presentTopText:(NSString *)text asError:(BOOL *)asError {
    self.topText.hidden = false;
    self.startStopButton.hidden = true;
    
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGSize expectedLabelSize = [text sizeWithFont:self.topText.font
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:self.topText.lineBreakMode];
    
    CGRect newFrame = self.topText.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.topText.frame = newFrame;

    
    if(asError) {
        self.topText.backgroundColor = [UIColor redColor];
        self.topText.textColor = [UIColor whiteColor];
    } else {
        self.topText.backgroundColor = Nil;
        self.topText.textColor = Nil;

    }
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

- (void)viewDidAppear:(BOOL)animated {
    [self reloadPreferences];
    [self handlePreferences];
    [self loadCurrentTimer];
}

@end
