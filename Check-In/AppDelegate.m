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
@property (nonatomic,strong) UINavigationController* navController;
@property (nonatomic,strong) HomeViewController* homeController;

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

/*
 -(void)handleEventForRegion:(CLCircularRegion*)region {
 // Show an alert if application is active
 if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
 if let message = notefromRegionIdentifier(region.identifier) {
 if let viewController = window?.rootViewController {
 showSimpleAlertWithTitle(nil, message: message, viewController: viewController)
 }
 }
 } else {
 // Otherwise present a local notification
 var notification = UILocalNotification()
 notification.alertBody = notefromRegionIdentifier(region.identifier)
 notification.soundName = "Default";
 UIApplication.sharedApplication().presentLocalNotificationNow(notification)
 }
 }
 
 func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
 if region is CLCircularRegion {
 handleRegionEvent(region)
 }
 }
 
 func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
 if region is CLCircularRegion {
 handleRegionEvent(region)
 }
 }
 
 func notefromRegionIdentifier(identifier: String) -> String? {
 if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
 for savedItem in savedItems {
 if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Geotification {
 if geotification.identifier == identifier {
 return geotification.note
 }
 }
 }
 }
 return nil
 }
 */
@end
