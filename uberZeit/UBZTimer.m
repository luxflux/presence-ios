//
//  Timer.m
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZTimer.h"

@implementation UBZTimer

- (UBZTimer *)initWithJSON:(NSData *)json_data {
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:json_data options:NSJSONReadingMutableLeaves error:&myError];
    
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
    
    return timer;
}

- (UBZTimer *)initStoppedTimer {
    UBZTimer *timer = [[UBZTimer alloc] init];
    timer.duration = @"00:00";
    timer.running = NO;
    return timer;
}

@end