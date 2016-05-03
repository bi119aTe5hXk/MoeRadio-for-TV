//
//  AppDelegate.m
//  MoeRadio for TV
//
//  Created by bi119aTe5hXk on 2015/09/27.
//  Copyright © 2015年 HT&L. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Init...");
    NSLog(@"Powered by");
    NSLog(@" __   __              __            ");
    NSLog(@"|  ＼／  |           ／ _|           ");
    NSLog(@"| ＼  ／ | ___   ___| |_ ___  __  __ ");
    NSLog(@"| |＼／| |／_ ＼/  _ ＼  _／_ ＼| | | |");
    NSLog(@"| |   | |  (_) |  __／ || (_) | |_| |");
    NSLog(@"|_|   |_|＼___／＼___|_| ＼___／＼__,_|");
    NSLog(@"Product by ©HT&L 2009-2016, Developer: @bi119aTe5hXk. @Ariagle. @gregwym.");
    NSLog(@"なにこれ(°Д°)？！");
    // Override point for customization after application launch.
    @synchronized (self) {
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // Allow application to recieve remote control
    [application beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
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
