//
//  ViewController.h
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBZTimer.h"


@interface UBZTimerViewController : UIViewController

- (IBAction)startStopButtonPressed;
- (void)timerLoadingFailed:(NSString *)error;
- (void)timerLoadingCompleted:(UBZTimer *)timer;

@end
