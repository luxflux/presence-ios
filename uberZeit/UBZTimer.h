//
//  Timer.h
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBZTimer : NSObject

@property (nonatomic, strong) NSNumber* time_type_id;
@property (nonatomic, strong) NSDate* start;
@property (nonatomic, strong) NSDate* end;
@property (nonatomic, strong) NSString* duration;
@property (nonatomic) BOOL running;

@end

