//
//  UBZSettings.m
//  uberZeit
//
//  Created by Raffael Schmid on 21.05.14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZSettingsViewController.h"

@implementation UBZSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.keychain = [UYLPasswordManager sharedInstance];
    
    self.apiURLField.text = [self.keychain keyForIdentifier:@"api_url"];
    self.apiKeyField.text = [self.keychain keyForIdentifier:@"api_key"];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *key;
    if(textField == self.apiURLField) {
        key = @"api_url";
    } else if (textField == self.apiKeyField) {
        key = @"api_key";
    } else {
        NSLog(@"w00t unknown field %@", textField);
    }
    
    if(key) {
        [self.keychain registerKey:textField.text forIdentifier:key];
        NSLog(@"Wrote %@ for %@", textField.text, key);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
