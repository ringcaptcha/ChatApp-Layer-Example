//
//  AppDelegate.m
//  ChatApp
//
//  Created by Martin Cocaro on 6/10/15.
//  Copyright (c) 2015 RingCaptcha. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "AppDelegate.h"
#import "ConvListViewController.h"

#import <Ringcaptcha/Ringcaptcha.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self loadSecrets];
    
    [self setupLayer];
    
    [self presentConversationList];
    
    return YES;
}

- (void)loadSecrets {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"plist"];
    if (path) {
        self.secrets = [NSDictionary dictionaryWithContentsOfFile:path];
    }
}

- (void)setupLayer {
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:[self.secrets objectForKey:@"LayerAppId"]];
    self.layerClient = [LYRClient clientWithAppID:appID];
    
    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to connect to Layer: %@", error);
        }
    }];
}

- (void)presentTwoStepVerification {
    [Ringcaptcha verifyOnboardWithAppKey:[self.secrets objectForKey:@"RingCaptchaAppKey"] andSecretKey:[self.secrets objectForKey:@"RingCaptchaSecretKey"] inViewController:((UINavigationController*)self.window.rootViewController).visibleViewController delegate:nil success:^(RingcaptchaVerification *verification) {
        
        if (self.layerClient.isConnected && !self.layerClient.isConnecting) {
            [self authenticateUserToLayer:verification.phoneNumber];
        }
        
    } cancel:^(RingcaptchaVerification *verification) {
        NSLog(@"Process canceled.");
    }];
}

- (void)authenticateUserToLayer:(NSString*) user {
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if( error ) {
            NSLog(@"error: %@",error.description);
        }
        
        NSString *identityToken = [self getIdentityTokenForUser:user withNonce:nonce];
        
        [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
            if( error ) {
                NSLog(@"error: %@",error.description);
            }
            [self presentConversationList];
        }];
        
    }];
}

- (NSString*)getIdentityTokenForUser:(NSString*) user withNonce:(NSString*) nonce {
    NSString *identityToken = nil;
    NSURLResponse *authResponse = nil;
    NSError *authError = nil;
    
    NSString *encodedNonce = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                   (CFStringRef)nonce,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingUTF8 ));
    
    NSString *authServer = [NSString stringWithFormat:[self.secrets objectForKey:@"AuthenticationURL"],user,encodedNonce];

    NSMutableURLRequest *authRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:authServer]];
    [authRequest setHTTPMethod:@"GET"];
    
    NSData *authData = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:&authResponse error:&authError];
    
    if (authError == nil && authData != nil) {
        identityToken = [[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding];
    }
    return identityToken;
}

- (void)presentConversationList {
    if (!self.layerClient.authenticatedUserID) {
        NSLog(@"Layer not authenticated, requiring 2-step verification process");
        
        [self presentTwoStepVerification];
    } else {
        NSLog(@"Authenticated as User: %@", self.layerClient.authenticatedUserID);
        
        ConvListViewController *controller = [ConvListViewController  conversationListViewControllerWithLayerClient:self.layerClient];
        [(UINavigationController *)self.window.rootViewController pushViewController:controller animated:YES];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
