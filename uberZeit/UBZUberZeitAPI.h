//
//  UBZTimerAPI.h
//  uberZeit
//
//  Created by Raffael Schmid on 24/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBZTimerViewController.h"

@interface UBZUberZeitAPI : NSObject

@property (nonatomic, weak) NSString *api_url;
@property (nonatomic, weak) NSString *api_key;

@property (nonatomic, strong) UBZTimerViewController *callback_object;

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) NSInteger responseCode;

-(id)initWithCallbackObject:(UBZTimerViewController *)callback_object;
-(void)updateApiURL:(NSString *)api_url;
-(void)updateApiKey:(NSString *)api_key;

-(void)loadCurrentTimer;

@end
