//
//  ViewController.m
//  WebServiceCallSample1
//
//  Created by Seals, Morris D on 11/6/14.
//  Copyright (c) 2014 Seals, Morris D. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSLog(@"aaa Running on %@ thread", [NSThread currentThread]);
    NSLog(@"Am I in the Main UI thread? %d", [NSThread isMainThread]);

    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    NSURLSessionConfiguration *myNSURLSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession *myNSURLSession = [NSURLSession sessionWithConfiguration:myNSURLSessionConfiguration delegate:nil delegateQueue:nil];

    NSString *urlNSString = @"https://www.googleapis.com/books/v1/volumes?q=ios";

    NSURL *myNSURL = [NSURL URLWithString:urlNSString];
    
    NSMutableURLRequest *myNSMutableURLRequest = [NSMutableURLRequest requestWithURL:myNSURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [myNSMutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [myNSMutableURLRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [myNSMutableURLRequest setHTTPMethod:@"GET"];

    
    /*

    [myNSMutableURLRequest setHTTPMethod:@"POST"];
    NSDictionary *mapData = [[NSDictionary alloc] initWithObjectsAndKeys:@"212333333",@"ABCD",@"6544345345",@"NMHG",
                             nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:&error];
    [myNSMutableURLRequest setHTTPBody:postData];
    */
    
    
    
    //NSURLSessionDataTask *myNSURLSessionDataTask =  [myNSURLSession dataTaskWithURL:myNSURL completionHandler:^(NSData *myNSData, NSURLResponse *myNSURLResponse, NSError *error) {
    
    NSURLSessionDataTask *myNSURLSessionDataTask =  [myNSURLSession dataTaskWithRequest:myNSMutableURLRequest completionHandler:^(NSData *myNSData, NSURLResponse *myNSURLResponse, NSError *error) {

        
        if (error) {
            
            NSLog(@"%@", [error localizedDescription]);
            
        } else {
            if ( [myNSURLResponse isKindOfClass:[NSHTTPURLResponse class]] ) {
                NSHTTPURLResponse *myNSHTTPURLResponse = (NSHTTPURLResponse *)myNSURLResponse;
                NSInteger statusCodeNSInteger = [myNSHTTPURLResponse statusCode];
                NSLog(@"[statusCodeNSInteger] %ld", (long)statusCodeNSInteger);
                
                if ( statusCodeNSInteger == 200 ) {
                    NSLog(@"We got an favorable status code of:  200.");
                    
                    NSDictionary *dicHeaders = [myNSHTTPURLResponse allHeaderFields];
                    NSUInteger sizeDicHeaders = [dicHeaders count];
                    NSLog(@"[sizeDicHeaders] %lu", (unsigned long)sizeDicHeaders);
                    
                    NSLog(@"-----------------------------------Start writing out NSHTTPURLResponse keys and values");
                    
                    NSArray *keys = [dicHeaders allKeys];
                    for(int i = 0; i < [keys count]; i++){
                        NSLog(@"Key:     %@,            Value:     %@\n", [keys objectAtIndex:i], [dicHeaders objectForKey:[keys objectAtIndex:i]]);
                        if([[keys objectAtIndex:i] caseInsensitiveCompare:@"CONTENT-TYPE"] == NSOrderedSame){
                            NSLog(@"[%@] %@", [keys objectAtIndex:i], [dicHeaders objectForKey:[keys objectAtIndex:i]]);
                        }
                    }
                    
                    NSLog(@"-----------------------------------Completed writing out NSHTTPURLResponse keys and values");

                    NSLog(@" ");
                    NSLog(@" ");
                    NSLog(@" ");

                    if (myNSData){
                        
                        NSUInteger lengthData = [myNSData length];
                        NSLog(@"[lengthData] %lu", (unsigned long)lengthData);
                        
                        NSString *bodyStringUTF8 = [[NSString alloc] initWithData:myNSData encoding:NSUTF8StringEncoding];
                        NSLog(@"[bodyStringUTF8 length] %lu", (unsigned long)[bodyStringUTF8 length]);
                        
                        NSLog(@" ");
                        NSLog(@" ");
                        NSLog(@" ");
                        NSLog(@"-----------------------------------Start writing out data as NSString.");

                        NSLog(@"%@", bodyStringUTF8);
                        
                        NSLog(@"-----------------------------------End writing out data as NSString.");
                        NSLog(@" ");
                        NSLog(@" ");
                        NSLog(@" ");
                        
                        NSLog(@"-----------------------------------Start writing out data as NSDictionary.");
                        NSDictionary *myNSDictionary = [NSJSONSerialization JSONObjectWithData:myNSData options:0 error:nil];
                        NSLog(@"%@", myNSDictionary);
                        NSLog(@"-----------------------------------End writing out data as NSDictionary.");
                        NSLog(@" ");
                        NSLog(@" ");
                        NSLog(@" ");
                        
                        
                        NSLog(@"bbbb Running on %@ thread", [NSThread currentThread]);
                        NSLog(@"Am I in the Main UI thread? %d", [NSThread isMainThread]);
                        
                        // We must phase back into the realm of the main UI thread, in order to update the UI.
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"ccc Running on %@ thread", [NSThread currentThread]);
                            NSLog(@"Am I in the Main UI thread? %d", [NSThread isMainThread]);
                            //[self.myUITableView  reloadData];
                        });
                        
                    } else {
                        NSLog(@"For some reason, we received no data.");
                    }

                    
                    
                } else {
                    NSLog(@"We got an unfavorable status code.");
                }
                
            }
        }
    
    }];
    
    [myNSURLSessionDataTask resume]; // This line is critical, and must stay here.
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    

    
    
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
