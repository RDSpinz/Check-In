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
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSDictionary* regionDictionary;
@property (strong, nonatomic) CLCircularRegion* intrepidOfficeLocation;
@end

@implementation HomeViewController 

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (CLCircularRegion*)dictToRegion:(NSDictionary*)dictionary {
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

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSString* message = [NSString stringWithFormat:@"%@ has arrived",self.nameTextField.text];
    [self postMessage:message];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSString* message = [NSString stringWithFormat:@"%@ has left the office",self.nameTextField.text];
    [self postMessage:message];

}

-(void)postMessage:(NSString*)message {
    NSString *baseURL = @"https://hooks.slack.com";
    NSString *path = @"/services/T026B13VA/B06F2555K/slGomBmY0zafWr3LPptdhWHj";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:message forKey:@"text"];
    [parameters setObject:@"#whos-here" forKey:@"channel"];
    [parameters setObject:@"ghost" forKey:@"icon_emoji"];
    [parameters setObject:self.nameTextField.text forKey:@"username"];
    
    AFHTTPSessionManager *afManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    afManager.requestSerializer = [AFJSONRequestSerializer serializer];
    afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [afManager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error while sending POST"
                                                            message:@"Sorry, try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}


@end
