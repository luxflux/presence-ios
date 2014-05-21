//
//  ViewController.h
//  uberZeit
//
//  Created by Raffael Schmid on 19/05/14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timer.h"


@interface UBZTimerViewController : UIViewController {
    IBOutlet UILabel *topText;
    IBOutlet UIButton *startStopButton;
        
    NSString *api_url;
    NSString *api_key;
}

- (IBAction)startStopButtonPressed;

@end
