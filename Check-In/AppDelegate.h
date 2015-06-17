//
//  AppDelegate.h
//  Check-In
//
//  Created by Randall Spence on 6/16/15.
//  Copyright (c) 2015 Randall Spence. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

