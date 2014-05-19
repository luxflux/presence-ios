//
//  ViewController.m
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "ViewController.h"
#import "Timer.h"


@interface ViewController ()

@end

@implementation ViewController

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
    
}

- (IBAction)buttonPressed {
    NSLog(@"Pressed!");
}

- (void)handleTimerUpdate {
    if([timer running]) {
        [self updateDuration];
    }
}
- (void)updateDuration {
    topText.text = timer.duration;
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
