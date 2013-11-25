//
//  ViewController.m
//  Golfrz
//
//  Created by Kevin Li on 11/24/13.
//  Copyright (c) 2013 Kevin Li. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) CLLocationManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

//- (IBAction)button:(id)sender;

@end

@implementation ViewController

@synthesize beaconManager, beaconRegion;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    beaconManager = [[CLLocationManager alloc]init];
    beaconManager.delegate = self;
    
    // set up the bacon
    NSUUID *beaconId = [[NSUUID alloc]initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    beaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:beaconId identifier:@"com.grumblus.beacon112413"];
    beaconRegion.notifyOnEntry = YES;
    beaconRegion.notifyOnExit = YES;
    [beaconManager startMonitoringForRegion:beaconRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
//- (IBAction)button:(id)sender {
    if (state == CLRegionStateInside) {
    
        NSLog(@"entered region");
        // POST to server
        NSMutableDictionary *innerDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"beacon_id", nil];
        NSMutableDictionary *outerDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:innerDictionary, @"checkin", nil];
        
        // convert dictionaries to JSON
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:outerDictionary options:NSJSONWritingPrettyPrinted error:&jsonError];
        
        NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.1.15:3000/checkins"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:[NSData dataWithBytes:[jsonData bytes] length:[jsonData length]]];
        // start taskbar spinner
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        
        // send the request synchronously
        NSURLResponse *response;
        NSError *error;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];

        
        // send user notification
        UILocalNotification *localNotification = [[UILocalNotification alloc]init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        localNotification.alertBody = @"Entered beacon region.";
        [[UIApplication sharedApplication]scheduleLocalNotification:localNotification];
    }
    else {
        NSLog(@"not in region");
    }
}

@end
