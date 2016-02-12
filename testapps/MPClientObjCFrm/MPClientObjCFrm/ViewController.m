//
//  ViewController.m
//  MPClientObjCFrm
//
//  Created by Richard Rosiak on 2/5/15.
//  Copyright (c) 2015 Richard Rosiak. All rights reserved.
//

#import "ViewController.h"
#import <GRIDMobileSDK/GRIDMobileSDK.h>

@interface ViewController ()

@property (nonatomic, strong) PGMClient *gridClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)signInTapped:(id)sender {
    self.Messages.text = @"";
    
    PGMAuthOptions *clientOptions = [[PGMAuthOptions alloc] initWithClientId:@"wkLZmUJAsTSMbVEI9Po6hNwgJJBGsgi5"
                                                             andClientSecret:@"SAftAexlgpeSTZ7n"
                                                              andRedirectUrl:@"http://int-piapi.stg-openclass.com/pi_group12client"];
    
    self.gridClient = [[PGMClient alloc] initWithEnvironmentType:PGMStagingEnv andOptions:clientOptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInError:) name:@"LoginFailure" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInComplete:) name:@"LoginSuccess" object:nil];
    
    //__block PGMAuthenticatedContext *authContextToStore = nil;
    //__block NSInteger interval;
    
    AuthenticationRequestComplete onComplete = ^(PGMAuthResponse *response) {
        //dispatch_async(dispatch_get_main_queue(), ^{ // execute the completion block on the main thread, if necessary
            if (response.error) {
                //error condition during login
                //self.Messages.text = response.error.description;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailure" object:response];
                });
            }
            else {
                //login success - authenticated context returned
                //authContextToStore = response.authContext;
                //interval = response.authContext.tokenExpiresIn;
                NSLog(@"On complete success!! Access token is %@", response.authContext.accessToken);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:response];
                });
            }
        //});
    };
    
    [[self.gridClient authenticator] authenticateWithUserName:self.Username.text
                                                  andPassword:self.password.text
                                                   onComplete:onComplete];
    
    //[NSThread sleepForTimeInterval:2.0];
    //NSLog(@"Done sleeping - will populate msg view...and access token from auth context to store is: %@", authContextToStore. accessToken);
    //NSLog(@"Interval is: %ld", interval);
    
    //self.Messages.text = [NSString stringWithFormat:@"%@\n%@\n%ld", authContextToStore.accessToken,
    //                      authContextToStore.refreshToken, (long)authContextToStore.tokenExpiresIn];
}

-(void) signInComplete:(NSNotification*) notification {
    
    [self removeObservers];
    
    NSLog(@"Sign in complete...");
    PGMAuthResponse *respnseFromNotification = (PGMAuthResponse*)notification.object;
    
    self.Messages.text = [NSString stringWithFormat:@"%@\n%@\n%ld", respnseFromNotification.authContext.accessToken,
                                                respnseFromNotification.authContext.refreshToken,
                                                (long)respnseFromNotification.authContext.tokenExpiresIn];
}

-(void) signInError:(NSNotification*) notification {
    
    [self removeObservers];
    
    NSLog(@"Failure trying to sign in...");
    PGMAuthResponse *respnseFromNotification = (PGMAuthResponse*)notification.object;
    self.Messages.text = respnseFromNotification.error.description;
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginFailure" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccess" object:nil];
}

@end
