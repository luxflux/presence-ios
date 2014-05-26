//
//  UBZTimerAPI.m
//  uberZeit
//
//  Created by Raffael Schmid on 24/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZUberZeitAPI.h"
#import "UBZTimer.h"
#import "UBZTimerViewController.h"


@interface UBZTimerLoading : UBZUberZeitAPI

-(void)start;

@end


@interface UBZTimerStopping : UBZUberZeitAPI

-(void)start;

@end


@implementation UBZUberZeitAPI

-(id)initWithCallbackObject:(id)callback_object withApiURL:(NSString *)api_url withApiKey:(NSString *)api_key {
    self = [super init];
    self.callback_object = callback_object;
    
    [self updateApiURL:api_url];
    [self updateApiKey:api_key];
    
    return self;
}

-(void)updateApiURL:(NSString *)api_url {
    self.api_url = api_url;
}

-(void)updateApiKey:(NSString *)api_key {
    self.api_key = api_key;
}

-(void)getRequest:(NSString *)uri {
    NSString *timer_url = [NSString stringWithFormat:@"%@%@", self.api_url, uri];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:timer_url]];
    
    // Create a mutable copy of the immutable request and add more headers
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest setValue:self.api_key forHTTPHeaderField:@"X-Auth-Token"];
    
    // Now set our request variable with an (immutable) copy of the altered request
    request = [mutableRequest copy];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    self.responseData = [[NSMutableData alloc] init];
    [self.responseData setLength:0];
    self.responseCode = response.statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
    [self.callback_object timerLoadingFailed:error.localizedDescription];
}

- (void)loadTimer {
    UBZTimerLoading *loader = [[UBZTimerLoading alloc] initWithCallbackObject:self.callback_object
                                                                   withApiURL:self.api_url
                                                                   withApiKey:self.api_key];
    [loader start];
}
- (void)stopTimer {
    UBZTimerStopping *stopper = [[UBZTimerStopping alloc] initWithCallbackObject:self.callback_object
                                                                      withApiURL:self.api_url
                                                                      withApiKey:self.api_key];
    [stopper start];
}

@end




@implementation UBZTimerLoading

-(void)start {
    [self getRequest:@"/api/timer"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Request succeeded! Received %d bytes of data",[self.responseData length]);
    switch(self.responseCode) {
        case 200: { // Timer running
            
            // convert to JSON
            NSError *myError = nil;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
            
            NSDateFormatter *uberZeitDateFormatter = [[NSDateFormatter alloc] init];
            [uberZeitDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            
            NSString *start = [NSString stringWithFormat:@"%@ %@", [res objectForKey:@"date"], [res objectForKey:@"start"]];
            
            UBZTimer *timer = [[UBZTimer alloc] init];
            timer.time_type_id = [res objectForKey:@"time_type_id"];
            timer.start = [uberZeitDateFormatter dateFromString:start];
            timer.end = [res objectForKey:@"end"];
            timer.duration = [res objectForKey:@"duration"];
            
            if([timer.end isKindOfClass:[NSNull class]]) {
                timer.running = YES;
            } else {
                timer.running = NO;
            }
            
            [self.callback_object timerLoadingCompleted:timer];
            
            break;
        }
        case 401: { // API Token wrong?
            [self.callback_object timerLoadingFailed:@"HTTP Code 401: Auth Token wrong?"];
            break;
        }
        case 404: { // No Timer running
            UBZTimer *timer = [[UBZTimer alloc] init];
            
            timer.duration = @"00:00";
            timer.running = NO;
            
            [self.callback_object timerLoadingCompleted:timer];
            
            break;
        }
        case 422: { // Validation failed
            NSError *myError = nil;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
            
            NSLog(@"%@", [res objectForKey:@"errors"]);
            [self.callback_object timerLoadingFailed:@"HTTP Code 422: Validation failed"];
            break;
        }
        case 500: { // Server failed hard
            [self.callback_object timerLoadingFailed:@"HTTP Code 500: Server got a hiccup"];
            NSLog(@"Server failed hard");
            break;
        }
        default: {
            NSLog(@"%d", self.responseCode);
        }
    }
}

@end

@implementation UBZTimerStopping

- (void)start {
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
    
    //[self.callback_object timerStoppingCompleted:timer];
}
@end

