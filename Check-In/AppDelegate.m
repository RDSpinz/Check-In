//
//  AppDelegate.m
//  Check-In
//
//  Created by Randall Spence on 6/16/15.
//  Copyright (c) 2015 Randall Spence. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"

@interface AppDelegate ()
@property (strong, nonatomic) UINavigationController* navController;
@property (strong, nonatomic) HomeViewController* homeController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    self.homeController = [[HomeViewController alloc] init];
    self.navController = [[UINavigationController alloc] init];
    self.window.rootViewController = _navController;
    [self.window makeKeyAndVisible];
    
    [self.navController pushViewController:self.homeController animated:NO];
    self.navController.delegate = self;
    
    self.navController.navigationBar.barTintColor = [UIColor darkGrayColor];
    self.navController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navController.navigationBar.translucent = NO;
    
    return YES;
}

@end
