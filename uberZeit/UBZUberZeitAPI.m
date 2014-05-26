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
    NSMutableURLRequest *request = [self prepareRequest:uri];
    [NSURLConnection connectionWithRequest:request delegate:self];
}


- (void)putRequest:(NSString *)uri withDictionary:(NSMutableDictionary *)dictionary {
    NSMutableURLRequest *request = [self prepareRequest:uri];
    
    request.HTTPMethod = @"PUT";
    
    NSData *jsonData = [self jsonSerializeDictionary:dictionary];
    [request setHTTPBody: jsonData];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(NSMutableURLRequest *)prepareRequest:(NSString *)uri {
    NSString *timer_url = [NSString stringWithFormat:@"%@%@", self.api_url, uri];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
                                    [NSURL URLWithString:timer_url]];
    
    [request setValue:self.api_key forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

- (NSData *)jsonSerializeDictionary:(NSMutableDictionary *)dictionary {
    
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&jsonSerializationError];
    
    return jsonData;
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

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Request succeeded! Received %d bytes of data, Response Code %i",[self.responseData length], self.responseCode);
}
@end




@implementation UBZTimerLoading

-(void)start {
    [self getRequest:@"/api/timer"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];
    
    switch(self.responseCode) {
        case 200: { // Timer running
            
            UBZTimer *timer = [[UBZTimer alloc] initWithJSON:self.responseData];
            
            [self.callback_object timerLoadingCompleted:timer];
            
            break;
        }
        case 401: { // API Token wrong?
            [self.callback_object timerLoadingFailed:@"HTTP Code 401: Auth Token wrong?"];
            break;
        }
        case 404: { // No Timer running
            
            UBZTimer *timer = [[UBZTimer alloc] initStoppedTimer];
            
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
    NSMutableDictionary *timerDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
    [timerDictionary setObject:@"now" forKey:@"end"];
    
    [self putRequest:@"/api/timer" withDictionary:timerDictionary];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [super connectionDidFinishLoading:connection];
    
    switch(self.responseCode) {
        case 200: { // Timer running
            UBZTimer *timer = [[UBZTimer alloc] initWithJSON:self.responseData];
            [self.callback_object timerStoppingCompleted:timer];
            
            break;
        }
        case 401: { // API Token wrong?
            [self.callback_object timerStoppingFailed:@"HTTP Code 401: Auth Token wrong?"];
            break;
        }
        case 404: { // No Timer running
            
            UBZTimer *timer = [[UBZTimer alloc] initStoppedTimer];
            
            [self.callback_object timerStoppingCompleted:timer];
            
            break;
        }
        case 422: { // Validation failed
            NSError *myError = nil;
            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
            
            NSLog(@"%@", [res objectForKey:@"errors"]);
            [self.callback_object timerStoppingFailed:@"HTTP Code 422: Validation failed"];
            break;
        }
        case 500: { // Server failed hard
            [self.callback_object timerStoppingFailed:@"HTTP Code 500: Server got a hiccup"];
            NSLog(@"Server failed hard");
            break;
        }
        default: {
            NSLog(@"%d", self.responseCode);
        }
    }
}
@end

