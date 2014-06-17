//
//  UBZSettings.m
//  uberZeit
//
//  Created by Raffael Schmid on 21.05.14.
//  Copyright (c) 2014 raffaelschmid. All rights reserved.
//

#import "UBZSettingsViewController.h"
#import "UBZUberZeitAPI.h"

@implementation UBZSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.keychain = [UYLPasswordManager sharedInstance];
    
    self.apiURLField.text = [self.keychain keyForIdentifier:@"api_url"];
    self.apiKeyField.text = [self.keychain keyForIdentifier:@"api_key"];
    
    [self.apiURLField setReturnKeyType:UIReturnKeyDone];
    [self.apiKeyField setReturnKeyType:UIReturnKeyDone];
    
    self.api_url = self.apiURLField.text;
    self.api_key = self.apiKeyField.text;
    
    [self.tableView setAllowsSelection:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.resultLabel.hidden = true;
    self.testSettingsButton.hidden = false;
    [self.testSettingsActivityIndicator stopAnimating];
    
    NSLog(@"End editting");
    
    NSString *key;
    if(textField == self.apiURLField) {
        self.api_url = self.apiURLField.text;
        key = @"api_url";
    } else if (textField == self.apiKeyField) {
        self.api_key = self.apiKeyField.text;
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

- (void)testSettingsButtonPressed {
    [self.testSettingsActivityIndicator startAnimating];
    self.testSettingsButton.hidden = true;
    self.resultLabel.hidden = true;
    [self performSelector:@selector(pingApi) withObject:NULL afterDelay:1.0];
}

- (void)pingApi {
    UBZUberZeitAPI *uberzeit_api = [[UBZUberZeitAPI alloc] initWithCallbackObject:self withApiURL:self.api_url withApiKey:self.api_key];
    [uberzeit_api pingAPI];
}

- (void)pingApiCompleted {
    NSLog(@"completed");
    [self.testSettingsActivityIndicator stopAnimating];
    self.resultLabel.text = @"It works!";
    self.resultLabel.hidden = false;
}

- (void)pingApiFailed:(NSString *)error {
    NSLog(@"failed");
    [self.testSettingsActivityIndicator stopAnimating];
    self.resultLabel.text = error;
    self.resultLabel.hidden = false;
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
