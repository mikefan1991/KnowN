//
//  AppDelegate.m
//  LinC
//
//  Created by Yingwei Fan on 8/7/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "AppDelegate.h"
#import "BRSDKHelper.h"
#import <Hyphenate/Hyphenate.h>
#import "BRTabBarController.h"
#import "BRLoginViewController.h"
#import "BRClientManager.h"
#import <SAMKeychain.h>
#import "BRCoreDataManager.h"


@interface AppDelegate () <EMClientDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *appkey = @"1153170608178531#linc-dev";
    NSString *apnsCertName = @"";
    [[BRSDKHelper shareHelper] hyphenateApplication:application
                      didFinishLaunchingWithOptions:launchOptions
                                             appkey:appkey
                                       apnsCertName:apnsCertName
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    if ([EMClient sharedClient].options.isAutoLogin) {
        // 之前登录过，可以显示主界面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        BRTabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BRTabBarController"];
        
        self.window.rootViewController = vc;
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Account" bundle:[NSBundle mainBundle]];
        BRLoginViewController *loginVc = [storyboard instantiateInitialViewController];
        self.window.rootViewController = loginVc;
    }
    [self setupOptions];
    
    //初始化数据库
    [[BRCoreDataManager sharedInstance] managedObjectContext];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupOptions {
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].options setIsAutoAcceptGroupInvitation:YES];
}



@end
