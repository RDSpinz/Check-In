//
//  HomeViewController.m
//  Check-In
//
//  Created by Randall Spence on 6/16/15.
//  Copyright (c) 2015 Randall Spence. All rights reserved.
//

#import "HomeViewController.h"
#import "AFNetworking.h"

@import CoreLocation;

@interface HomeViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *startMonitoringButton;
@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) NSDictionary* regionDictionary;
@property (nonatomic,strong) CLCircularRegion* intrepidOfficeLocation;
@end

@implementation HomeViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Monitoring Button Pressed");
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:@"isMonitoring"] isEqualToString:@"YES"]) {
        self.startMonitoringButton.titleLabel.text = @"Stop Monitoring";
    } else {
        self.startMonitoringButton.titleLabel.text = @"Start Monitoring";
    }
    
    //Initialize Within 1 Mile of The Intrepid Pursuits Boston Location
    self.regionDictionary = @{ @"identifier" : @"Intrepid Boston Office", @"latitude": @42.367916, @"longitude" : @-71.080130, @"radius" : @1610 };
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    
    self.intrepidOfficeLocation = [self dictToRegion:self.regionDictionary];
    
}

- (IBAction)startMonitoringPressed:(UIButton*)sender {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    NSLog(@"Monitoring Button Pressed");
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([sender.titleLabel.text isEqualToString:@"Start Monitoring"] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [defaults setValue:@"YES" forKey:@"isMonitoring"];
        [sender setTitle:@"Stop Monitoring" forState:UIControlStateNormal];
        
        [self.locationManager startMonitoringForRegion:self.intrepidOfficeLocation];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.region = self.intrepidOfficeLocation;
        localNotification.alertBody = @"Welcome to Intrepid Pursuits";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

        
    } else {
        [defaults setValue:@"NO" forKey:@"isMonitoring"];
        [sender setTitle:@"Start Monitoring" forState:UIControlStateNormal];
        
        [self.locationManager stopMonitoringForRegion:self.intrepidOfficeLocation];
    }
}

- (CLCircularRegion*)dictToRegion:(NSDictionary*)dictionary
{
    NSString *identifier = [dictionary valueForKey:@"identifier"];
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    if(regionRadius > _locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = _locationManager.maximumRegionMonitoringDistance;
    }
    
    CLCircularRegion * region = [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:regionRadius identifier:identifier];
    
    region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                radius:regionRadius
                                            identifier:identifier];
    
    return  region;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"STATUS DID CHANGE!");
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"You are at the office");
    
    NSString *baseURL = @"https://hooks.slack.com";
    NSString *path = @"/services/T026B13VA/B06F2555K/slGomBmY0zafWr3LPptdhWHj";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"Randall has arrived" forKey:@"text"];
//    [parameters setObject:@"#whos-here" forKey:@"channel"];
//    [parameters setObject:@"ghost" forKey:@"icon_emoji"];
//    [parameters setObject:@"Randall" forKey:@"username"];
    AFHTTPSessionManager *afManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [afManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        //here is place for code executed in success case
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Request body %@", [[NSString alloc] initWithData:[task.currentRequest HTTPBody] encoding:NSUTF8StringEncoding]);

        //here is place for code executed in success case
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error while sending POST"
                                                            message:@"Sorry, try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"You have left the office");
}



@end
