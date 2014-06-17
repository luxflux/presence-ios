//
//  UBZTimerAPI.h
//  uberZeit
//
//  Created by Raffael Schmid on 24/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBZUberZeitAPI : NSObject

@property (nonatomic, strong) NSString *api_url;
@property (nonatomic, strong) NSString *api_key;

@property (nonatomic, strong) id callback_object;

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) NSInteger responseCode;

-(id)initWithCallbackObject:(id)callback_object withApiURL:(NSString *)api_url withApiKey:(NSString *)api_key;
-(void)updateApiURL:(NSString *)api_url;
-(void)updateApiKey:(NSString *)api_key;

-(void)loadTimer;
-(void)stopTimer;
-(void)startTimer;

-(void)loadTimeTypes;

-(void)pingAPI;

@end
