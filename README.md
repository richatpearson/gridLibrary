# Pearson GRID Mobile iOS SDK Framework

##Overview
GRID Mobile iOS SDK is a Cocoa Touch framework. It enables mobile apps to easily accomplish GRID-related tasks by doing more than just bridging the gap to access GRID APIs. As an interface to GRID APIs it aggregates the calls when necessary to enable the app accomplishing complex requests with a single call. App developers no longer need to incorporate multiple frameworks in their projects, since GRID Mobile SDK provides functionality across many GRID modules, such as login, classroom, etc.

##Version
The current version is 2.0

##Specifications
* supports iOS 7 +
* supports both Objective-C and Swift apps

## Report Issues
Frequently asked questions and support from the GRID Mobile community can be found on the [Pearson Developers Network community support pages](http://pdn.pearson.com/community). Browse the forums for assistance or submit a new question.
You may also want to contact the developers in GRID Mobile Support HipChat room.

##Including GRID Mobile in your project

###Adding .framework
Download **GRIDMobileSDK.framework** from Nexus repository 
In Xcode...Project...your target...General...Embedded Binaries, simply reference **GRIDMobileSDK.framework**  you downloaded from Nexus and build your project.
The SDK requires the Security.framework for storing data in Keychain Services. 


###Using CocoaPods
The easiest way to incorporate the SDK into your project is to use CocoaPods. For information on setting up CocoaPods on your system, visit http://cocoapods.org/.

Adding the GRID Mobile CocoaPods specifications repository

```
pod repo add gridmobile-cocoapods ssh://git@devops-tools.pearson.com/mp/gridmobile-cocoapods.git
```

Create a PodFile for your project that specifies the grid-ios-sdk dependency. For example:

```
source 'ssh://git@devops-tools.pearson.com/mp/gridmobile-cocoapods.git'

target 'GridMobileClient' do
  pod 'grid-ios-sdk', '2.0.0'
end

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
```
The last part of Podfile sets Build Active Architectures Only to NO in your Pods project's target to avoid a build error in your workspace.

Then install the dependencies:

```
pod install
```
or
```
pod update
```
if you just need to update previously installed GRID Mmobile framework

Open the **_.xcworkspace_** file that manages the new dependencies for your project and you can begin to incorporate the sdk into your code.

###Swift apps
Swift code consuming GRID Mobile framework via Cocoa Pods needs to point to gridmobilesdk.h - its umbrella header file in Build Settings. This public header file is distributed with the framework. To do it, in Xcode go to Project...your target...Build Settings...Swift Compiler - Code Generation...Objective-C Bridging Header and point to where gridmobilesdk.h is located. After that you will be able to access GRIDMobileSDK's objects in your code, without even specifying import statements.

##Usage
When using .framework distribution - because GRID Mobile framework has an umbrella header file (gridmobilesdk.h) there is no need to import each class separately. All you need to do is reference the framework in a single import statement

####Objective-C
```
#import <GRIDMobileSDK/GRIDMobileSDK.h>
```

####Swift
```
import GRIDMobileSDK
```

and all public headers included in the umbrella header are available to your code.

####Create PGMAuthOptions object
Your app should obtain client id, client secret and redirect url from your authentication provider (such as Pi). With that information you can init PGMAuthOptions object:

####Objective-C
```
PGMAuthOptions *clientOptions = [[PGMAuthOptions alloc] initWithClientId:@"myClientId12345"
                                                             andClientSecret:@"mySecret"
                                                              andRedirectUrl:@"http://myRedirectUrl.com"];
```

####Swift
```
var clientOptions = PGMAuthOptions(clientId: "myClientId12345",
            andClientSecret: "mySecret", andRedirectUrl: "http://myRedirectUrl.com")
```

where "myClientId12345", "mySecret" and "myRedirectUrl.com" are obtained from your authentication provider (such as Pi).

####Create PGMClient object
Now you are ready to instantiate the Pearson GRID Mobile client in the environment of your choice. You may choose from these 3 environment types:

```
PGMStagingEnv
PGMProductionEnv
PGMCustomEnv
```

to init the client.

####Objective-C
```
PGMClient *gridClient = [[PGMClient alloc] initWithEnvironmentType:PGMStagingEnv andOptions:clientOptions];
```

####Swift:
```
var gridClient = PGMClient(environmentType: .StagingEnv, andOptions: clientOptions)
```

At this point the GRID client is ready to receive requests for user's authentication. 

###Authentication - login
All requests involving network calls, such as login, are done asynchronously and need a completion block to be passed in. The completion block for login is of type AuthenticationRequestComplete. Here are code examples of how user authentication could be done:

####Objective-C
```
AuthenticationRequestComplete onComplete = ^(PGMAuthResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{ // execute the completion block on the main thread, if necessary 
		if (response.error) {
            		//error condition during login 	
        	}
        	else {
			//login success - authenticated context returned
            		NSLog(@"On complete success! Access token is %@", response.authContext.accessToken);
                        //capture authContext
        	}
        }); 
};

[[gridClient authenticator] authenticateWithUserName:@"myusername" andPassword:@"mypassword" onComplete:onComplete];
```


####Swift
```
func signInComplete(response: PGMAuthResponse) {
        if (response.error != nil) {
		//error condition during login
        } else {
		//login success - authenticated context returned
                println("On complete success! Access token is \(response.authContext.accessToken)")
                //capture authContext
        }
}

gridClient.authenticator.authenticateWithUserName("myusername", andPassword: "mypassword", onComplete: { (authResponse: PGMAuthResponse!) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ // execute the completion block on the main thread, if necessary
                    self.signInComplete(authResponse)
                })
```

The response from GRID Mobile SDK is of type PGMAuthResponse. This object has a property - authContext, which encapsulates PGMAuthenticatedContext type. This authenticated context needs to be passed with all subsequent GRID Mobile requests. It contains tokens, user and username. Consider this sample code for storing the context in a property/variable:

####Objective-C
```
PGMAuthenticatedContext *authContext = response.authContext;
```

####Swift
```
var authContext = response.authContext
```

####Error Handling for Authentication
The response object - PGMAuthResponse - which is passed to AuthenticationRequestComplete block contains error property which is of type NSError. GRID mobile framework uses this property to cummnicate problems to the client app. The client apps needs to evaluate the int value of the error code found in `response.error.code` and (sometimes) its message. Here are the error codes for the authentication process:  
  
| Error Code | Enum Value                             | Message                                                      |
|------------|----------------------------------------|--------------------------------------------------------------|
|      0     | PGMAuthenticationError                 | "Missing username."                                          |
|      0     | PGMAuthenticationError                 | "Missing password."                                          |
|      0     | PGMAuthenticationError                 | "One or more client options missing. Please provide client id, client secret and redirect url for Pi authentication" | 
|      0     | PGMAuthenticationError                 | "Missing environment."                                       | 
|      1     | PGMAuthInvalidCredentialsError         | "Invalid username or password"                               |   
|      2     | PGMAuthNoConsentError                  | "User missing consent"                                       |  
|      4     | PGMCoreNetworkCallError                | "Error executing NSURL session task"                         | 
|      4     | PGMCoreNetworkCallError                | "Non-200 HTTP status code"                                   | 
|      4     | PGMCoreNetworkCallError                | "Response type is not NSHTTPURLResponse"                     | 
|      5     | PGMAuthUserIdError                     | "Missing authenticated context for user Id request"          |
|      5     | PGMAuthUserIdError                     | "Username and access token are required for user Id request" |  
|      7     | PGMUnableToStoreContextInKeychainError | "Unable to store context in keychain."                       |  
|      9     | PGMAuthMaxRefuseConsentError           | "Max number of login attempts with missing consent reached." |  
|      14    | PGMAuthInvalidClientId                 | "Invalid client Id"                                          |  
|      24    | PGMProviderReturnedNoDataError         | "Pi login API returned no data"                              | 
 

###Athenticated Context and Keychain

As part of the login process GRIDMobileSDK framework securely stores the authenticated context (PGMAuthenticatedContext) in the keychain. The application may retrieve this data by calling retrieveKeychainDataWithIdentifier:key, where key is the Pi user Id which was used as an identifier to securely store the data in keychain. The Pi user Id is a property of PGMAuthenticatedContext - userIdentityId. Here is a usage example:

####Objective-C
```
NSData *data = [PGMSecureKeychainStorage retrieveKeychainDataWithIdentifier:authContext.userIdentityId];

PGMAuthenticatedContext *myContext = [NSKeyedUnarchiver unarchiveObjectWithData:data];
```

####Swift
```
var data = PGMSecureKeychainStorage.retrieveKeychainDataWithIdentifier(authContext.userIdentityId)

var myContext = NSKeyedUnarchiver.unarchiveObjectWithData(data) as PGMAuthenticatedContext
```

###User Consent Flow
When attempting to log in through Pi for the first time, the user may be required to consent to certain policies (e.g.: terms of use, privacy, etc). In this case the framework will return an error of type `PGMAuthNoConsentError` (int value of 2) in the login request's response object. The response will also contain an array of consent policy objects (`PGMConsentPolicy`) that will need to be reviewed and consented to by the user. Here is an example of how to pull this data from the response object.

####Objective-C
```
if (!response.error && response.error.code == 2) {
    NSArray *consentPolicies = response.consentPolicies;
}
```

####Swift
```
var consentPolicies: Array<PGMConsentPolicy>?

if (response.error != nil && response.error.code == 2) {
    consentPolicies = response.consentPolicies as Array<PGMConsentPolicy>
}
```

Each consent policy object contains a url that points to the text for that policy (`consentPageUrl`). There are also two boolean values to indicate if the user has been shown the policy (`isReviewed`) and if the user consented to the policy (`isConsented`). `PGMAuthResponse` - the response object - also has a property containing an escrow ticket - a ticket Pi returns that will be needed when posting user consents.

These policies should be shown to user one by one - each url needs to be rendered by the app and shown to user - for review and consent. After all policies have been cycled through and review and consent have been properly indicated (`isConsented = true` and `isReviewed = true`) for each consent policy, the array of consent policy objects can be returned through another framework call. Here are corresponding code examples:

####Objective-C
```
[gridClient.authenticator submitUserConsentPolicies:consentPolicies
                                       withUsername:username
                                           password:password
                                       escrowTicket:escrowTicket
                                         onComplete:onComplete];
```

####Swift
```
gridClient.authenticator.submitUserConsentPolicies(consentPolicies, withUsername: username, password: password, escrowTicket: escrowTicket, onComplete: onComplete)
```

####Consent Flow Error Handling
If user does not consent to one or more policy the framework will return an error of type `PGMAuthRefuseConsentError` - int value of 3 - in the response of the onComplete block (`response.error.code`) along with the array of PGMConsentPolicy types, just like for login of a non-consented user. The app should then again show the policies which user has not consented to. The framework will not submit the consent policies to Pi if at least one policy has not been consented to by the user.

The user only has 10 tries to consent to policies. A single try is a login attempt (not executing submitUserConsentPolicies method). If the 10 tries have been used up by the user the framework will return an error of type PGMAuthMaxRefuseConsentError - int value of 9 found in `response.error.code` - during a login attempt. In this case the user must contact a Pi System Administrator to have his/her escrow regenerated. 

Currently, in order to finish the login process, all policies must be reviewed and consented to. If this is the case, then after the SDK successfully posts the consents to Pi, the login process will be automatically executed and the app will be returned the response object with authenticated context. Authenticated context is stored in keychain at the end of successful login.

Here is the full list of errors that could be found in `respnse.error.code` relating to user consent flow:  

| Error Code | Enum Value                             | Message                                                      |
|------------|----------------------------------------|--------------------------------------------------------------|
|     3      | PGMAuthRefuseConsentError              | "User refused consent"                                       | 
|     4      | PGMCoreNetworkCallError                | "Error executing NSURL session task"                         |
|     4      | PGMCoreNetworkCallError                | "Non-200 HTTP status code"                                   |
|     4      | PGMCoreNetworkCallError                | "Response type is not NSHTTPURLResponse"                     |
|     8      | PGMAuthConsentFlowError                | "No escrow ticket included in request"                       | 
|     8      | PGMAuthConsentFlowError                | "No policy Ids included in request"                          | 
|     8      | PGMAuthConsentFlowError                | "Cannot deserialize escrow consent policies data"            | 
|     8      | PGMAuthConsentFlowError                | "No consent policies for user"                               | 
|     8      | PGMAuthConsentFlowError                | "Cannot deserialize post user consent policies data"         | 
|     8      | PGMAuthConsentFlowError                | "Pi returned failure posting user consents"                  |
|     9      | PGMAuthMaxRefuseConsentError           | "Max number of login attempts with missing consent reached." | 
|     24     | PGMProviderReturnedNoDataError         | "Escrow Policies API returned no data"                       | 
|     24     | PGMProviderReturnedNoDataError         | "Post user consent policies API returned no data"            | 

###Authentication - logout
The logout removes authenticated context from keychain for the user. The user will have to login again before the app can continue using GRID Mobile framework for additional data requests. Here are code examples of how to log out:

####Objective-C
```
PGMAuthResponse *signOutResponse = [gridClient.authenticator logoutUserWithAuthenticatedContext:authContext];
```

####Swift
```
var signOutResponse: PGMAuthResponse?
signOutResponse = gridClient!.authenticator.logoutUserWithAuthenticatedContext(authContext)
``` 

The PGMAuthenticatedContext object in signOutResponse is nil. The app should discard any previous copies of authenticated context.

####Error Handling for Logout
`response.error.code` may contain the following error codes:  
12 - Missing auth context (passed-in parameter) or missing user id in auth context.  
15 - Not able to delete user's auth context from keychain.  


###Forgot Username
This request requires a single piece of information - user's primary e-mail address. As with the other async request - completion handler block must also be provided. A successful request means Pi sent the username value to the provided e-mail. Here are examples of possible implementation:

####Objective-C
```
AuthenticationRequestComplete forgotUsernameCompletionHandler = ^(PGMAuthResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{ // execute the completion block on the main thread, if desired 
		if (response.error) {
            		//error condition 
        	}
        	else {
			//success - email address sent to user's primary e-mail 
        	}
        }); 
};

[gridClient.authenticator forgotUsernameForEmail:userEmail
                                      onComplete:forgotUsernameCompletionHandler]; 
```

####Swift
```
func performForgotUsernameWith(email: String) {
        self.client!.authenticator.forgotUsernameForEmail(email, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ // execute the completion block on the main thread, if desired
                self.forgotUsernameComplete(authResponse)
            })
        })
    }
   
func forgotUsernameComplete(response: PGMAuthResponse) {
    println("forgot username complete...")
    if (response.error != nil) {
       //error condition
    } else {
        //success - email address sent to user's primary e-mail 
    }
```

Just like with previous examples - the onComplete block is of type `AuthenticationRequestComplete` and the response object which framework will pass to the block is again `PGMAuthResponse`. In this case, however, it only serves as a vehicle to comunicate errors, not to provide new authenticated context. No error in resposne means the request was successful.

####Error Handling for Forgot Username
As with previous requests the error property of the PGMAuthResponse object constains information for the client app what went wrong. The integer values of the `response.error.code` is as follows:  

| Error Code | Enum Value                        | Message                                                               |
|------------|-----------------------------------|-----------------------------------------------------------------------|
|      4     | PGMCoreNetworkCallError           | "Error executing NSURL session task"                                  |
|      4     | PGMCoreNetworkCallError           | "Non-200 HTTP status code"                                            |
|      4     | PGMCoreNetworkCallError           | "Response type is not NSHTTPURLResponse"                              |
|      16    | PGMAuthInvalidEmailError          | "Invalid email"                                                       |
|      17    | PGMAuthEmailNotFound              | "No such e-mail address found"                                        |  
|      18    | PGMAuthUnknownForgotUsernameError | "Unknown error while calling Forgot Username. Please try again later" |
|      24    | PGMProviderReturnedNoDataError    | "Pi Forgot Username API returned no data" | 

###Forgot Password
Forgot password is very similar to forogot username request. The difference is - the app client must provide the username. Here are examples:

####Objective-C
```
AuthenticationRequestComplete forgotPasswordCompletionHandler = ^(PGMAuthResponse *response) {
        dispatch_async(dispatch_get_main_queue(), ^{ // execute the completion block on the main thread, if desired
                if (response.error) {
                        //error condition
                }
                else {
                        //success - email address sent to user's primary e-mail
                }
        });
};

[gridClient.authenticator forgotPasswordForUsername:username
                                      onComplete:forgotPasswordCompletionHandler];
```

####Swift
```
func performForgotPasswordWith(username: String) {
    self.client!.authenticator.forgotPasswordForUsername(username, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
        NSOperationQueue.mainQueue().addOperationWithBlock({ // execute the completion block on the main thread, if desired
            self.forgotPasswordComplete(authResponse)
        })
    })
}

func forgotPasswordComplete(response: PGMAuthResponse) {
    if (response.error != nil) {
       // error condition 
    } else {
        //success - email has been sent to user's primary email address
    }
}
```

####Error Handling for Forgot Password
The integer values of the `response.error.code` is as follows:  

| Error Code | Enum Value                            | Message                                                               |
|------------|---------------------------------------|-----------------------------------------------------------------------|
|     4      | PGMCoreNetworkCallError               | "Error executing NSURL session task"                                  |
|     4      | PGMCoreNetworkCallError               | "Non-200 HTTP status code"                                            |
|     4      | PGMCoreNetworkCallError               | "Response type is not NSHTTPURLResponse"                              |
|     19     | PGMAuthUnknownForgotPasswordError     | "Unknown error while calling Forgot Password. Please try again later" |  
|     20     | PGMAuthMissingUsernameError           | "Username is required for 'forgot password' request"                  |
|     21     | PGMAuthUsernameNotFoundError          | "No such username found"                                              |  
|     22     | PGMAuthMaxForgotPasswordExceededError | "User exceeded max number of requesting password reset w/out actually resetting the password. Please contact system administrator." | 
|     24     | PGMProviderReturnedNoDataError        | "Pi Forgot Password API returned no data"                             | 

###Refreshing the Pi Access Token

Pi access token has an expiration time stamp which normally forces an app to either refresh it or have the user to sign in again. When using GRID Mobile SDK this problem goes away almost entirely. All that needs to be done is use a method included in the Authenticator class `obtainCurrentTokenForAuthContext:onComplete:` which will always return a current access token, even if refresh is necessary. The only exception is when the refresh token itself is expired, in which scenario user will have to sign in again. Here is an example of how this method could be consumed:

####Objective-C
```
//At this point the app should already have authContext as the result of the sign in process

AuthenticationRequestComplete obtainCurrentTokenCompletionHandler = ^(PGMAuthResponse *response) {
    dispatch_async(dispatch_get_main_queue(), ^{ // execute the completion block on the main thread, if desired
        if (response.error) {
            NSLog(@"An error getting current token: %@", response.error.description)")
            //error condition
        }
        else {
            NSLog(@"Success!! Current token is %@", response.authContext.accessToken);
            //Do calls with the valid access token
        }
    });
};

[gridClient.authenticator obtainCurrentTokenForAuthContext:authContext
                                                onComplete:obtainCurrentTokenCompletionHandler];
```

####Swift
```
//At this point the app should already have authContext as the result of the sign in process

func obtainCurrentToken(authContext: PGMAuthenticatedContext) {
    
    self.client!.authenticator.obtainCurrentTokenForAuthContext(authContext, onComplete: { (authResponse: PGMAuthResponse!) -> Void in
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.obtainCurrentTokenForContextComplete(authResponse)
        })
    })
}
    
func obtainCurrentTokenForContextComplete(authResponse: PGMAuthResponse) {
    
    if (authResponse.error != nil) {
        println("An error getting current token: \(authResponse.error.description)")
        
    } else {
        println("Success!! Current token is \(authResponse.authContext.accessToken)")
        
        //Do calls with the valid access token
    }
}
``` 

There is a remote possibility that access token obtained this way could be expired (corner-case scenario). In this case GRID Mobile SDK has another method -`obtainCurrentTokenForExpiredAuthContext:onComplete:`- which immediately uses the refresh call. Like the previous method, it can be accessed via the Authenticator class. NOTE: this method should only be used when the token is expired, meaning - while doing a request requiring access token in the header, client app received an error from Pi that the provided access token is expired.

The usage is the same as with the previous method. 
 
####Error Handling for Refresh Token Process

The integer values of the `response.error.code` is as follows:  

| Error Code | Enum Value                              | Message                                                          |
|------------|-----------------------------------------|------------------------------------------------------------------|
|     4      | PGMCoreNetworkCallError                 | "Error executing NSURL session task"                             |
|     4      | PGMCoreNetworkCallError                 | "Non-200 HTTP status code"                                       |
|     4      | PGMCoreNetworkCallError                 | "Response type is not NSHTTPURLResponse"                         |
|     6      | PGMAuthMissingContextError              | "Authenticated context for user must be provided"                |
|     7      | PGMUnableToStoreContextInKeychainError  | "Unable to store context in keychain."                           |
|     10     | PGMAuthUserLoggedOutError               | "No auth context in keychain - user must log in again."          |
|     11     | PGMAuthRefreshTokenExpiredError         | "Expired refresh token - please login again."                    |
|     12     | PGMAuthMissingUserIdError               | "User id must be provided as part of authenticated context"      | 
|     13     | PGMAuthMissingRefreshTokenError         | "Missing refresh token from context - please login again."       | 
|     23     | PGMAuthMissingAccessTokenInContextError | "Access token must be provided as part of authenticated context" |


###Classroom 
