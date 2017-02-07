//
//  YoReferSocial.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/24/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "YoReferSocial.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "YoReferAppDelegate.h"

@interface YoReferSocial ()

@property (nonatomic, strong) YoReferAppDelegate *appDelegate;

@end

#pragma mark -
@implementation YoReferSocial

+ (YoReferSocial *)shareYoReferSocial
{
    static YoReferSocial *_shareYoReferSocial = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareYoReferSocial = [[YoReferSocial alloc]init];
    });
    return _shareYoReferSocial;
}

- (void)faceBookWithDelegate:(id<Scocial>)delegate
{
    self.delegate = delegate;
    if ([FBSession activeSession].state != FBSessionStateOpen &&
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email",@"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [self sessionStateChanged:session state:state error:error];
         }];
    }
    else{
        // Close an existing session.
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
}
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn:session];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI

        //[self userLoggedOut];
        [self userLoggedIn:session];
        return;
    }
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}


// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Confirm logout message
    //[self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn :(FBSession *)session
{
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
         if (!error) {
             NSLog(@"user %@",user);
             NSLog(@"accesstoken %@",[NSString stringWithFormat:@"%@",session.accessTokenData]);
             NSLog(@"user id %@",user.objectID);
             NSLog(@"Email %@",[user objectForKey:@"email"]);
             NSLog(@"User Name %@",user.name);
             NSLog(@"User Name %@",user.first_name);
             NSLog(@"User Name %@",user.last_name);
             NSMutableDictionary *postDic=[[NSMutableDictionary alloc]init];
             
//             [postDic setValue:@"+911234567899" forKey:@"number"];
             [postDic setValue:[user objectForKey:@"email"] forKey:@"emailId"];
             [postDic setValue:[user objectForKey:@"id"] forKey:@"facebookId"];
             [postDic setValue:user.name forKey:@"name"];
             [postDic setValue:[NSString stringWithFormat:@"%@",session.accessTokenData] forKey:@"fbAccessToken"];
             
             // For profile Image fetching from FB account
             NSString *userImageURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", [user objectForKey:@"id"]];
             [postDic setValue:userImageURL forKey:@"dp"];


             
             if ([self.delegate respondsToSelector:@selector(faceBookUser:)])
             {
                 [self.delegate faceBookUser:postDic];
             }
            FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"/me/invitable_friends" parameters:nil HTTPMethod:@"GET"];
            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                           NSDictionary* result,
                                                           NSError *error) {
                 NSArray* friends = [result objectForKey:@"data"];
                 NSLog(@"Found: %lu friends", (unsigned long)friends.count);
                 for (NSDictionary<FBGraphUser>* friend in friends) {
                     NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
                 }
             }];
         }
     }];
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

@end
