//
//  LocationManager.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/16/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "LocationManager.h"
#import "UserManager.h"
#import "Constant.h"

@interface LocationManager ()
@property (nonatomic,   readwrite)  BOOL                isLocaltionUpdated;
@end

#pragma mark -
@implementation LocationManager
+ (LocationManager *)shareLocationManager
{
    static LocationManager *shareLocationManager = nil;
    static dispatch_once_t  onceToken;
    dispatch_once(&onceToken, ^{
        shareLocationManager = [[LocationManager alloc]init];
        
    });
    return shareLocationManager;
}
- (instancetype)initWithDelegate:(id<LocationManger>)delegate
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.isLocaltionUpdated = NO;
        [self getCurrentLocation];
        
    }
    return self;
}
- (void)getCurrentLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate        = self;
    self.locationManager.distanceFilter  = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy     = kCLLocationAccuracyBest;
    [self locationServiceAuthorization];
    [self.locationManager  requestAlwaysAuthorization];
    [ self.locationManager startMonitoringSignificantLocationChanges];
    self.locationManager.distanceFilter=10;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}
- (void)locationServiceAuthorization
{
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (!self.isLocaltionUpdated)
    {
        self.isLocaltionUpdated = YES;
        [[UserManager shareUserManager] setLatitude:[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude]];
        [[UserManager shareUserManager] setLongitude:[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude]];
        CLLocation *newLocation = [locations lastObject];
        CLGeocoder *gecoder=[[CLGeocoder alloc]init];
        [gecoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemark,NSError *error)
         {
             if (error==nil) {
                 CLPlacemark *placemarkResult=[placemark objectAtIndex:0];
                 NSDictionary  *address=[placemarkResult addressDictionary];
                 if ([self.delegate respondsToSelector:@selector(getCurrentLocationWithAddress:latitude:logitude:)])
                 {
                     [self.delegate getCurrentLocationWithAddress:address latitude:[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.latitude] logitude:[NSString stringWithFormat:@"%f",self.locationManager.location.coordinate.longitude]];
                 }
             }
         }];
    }
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Error
- (void)locationError:(NSError *)error {
    NSLog(@"%@", [error description]);
}

#pragma mark - Location Enable
-(BOOL)CheckForLocationService{
    BOOL isLocation;
    if([CLLocationManager locationServicesEnabled])
    {
        NSLog(@"%d",[CLLocationManager authorizationStatus]);
       if([CLLocationManager authorizationStatus]==0 || [CLLocationManager authorizationStatus] ==2)
       {
           isLocation=NO;
           [[UserManager shareUserManager] disableLocation];
        }else{
            [[UserManager shareUserManager] enableLocation];
            isLocation=YES;
        }
    }
    return isLocation;
}

#pragma mark - Location search
- (void)searchCityWithName:(NSString *)name :(locationSearchDetails)locationdetails
{
    if (name != nil && [name length] > 0)
    {
        NSString *placeURL=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=%@&types=(cities)",name,@"AIzaSyBZokl35NK2BIpKpnFB97PIyvlSOKng9E0"];
        NSLog(@"placeURl=%@",placeURL);
        NSURL *url = [NSURL URLWithString:[placeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        dispatch_queue_t imageQueue = dispatch_queue_create("Place Queue",NULL);
        dispatch_async(imageQueue, ^{
            NSData *getData = [NSData dataWithContentsOfURL:url];
            NSString *strResponse;
            strResponse=[[NSString alloc]initWithData:getData encoding:NSStringEncodingConversionAllowLossy];
            if (!strResponse) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[strResponse dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
                if ([jsonObject isKindOfClass:[NSDictionary class]])
                {
                    if ([[jsonObject valueForKey:@"predictions"] count])
                    {
                        NSMutableArray *array = [jsonObject valueForKey:@"predictions"];
                        locationdetails(array);
                        //[jsonObject valueForKey:@"predictions"]
                    }
                }
            });
            
        });
    }else
    {
    }
}

- (NSMutableDictionary *)getCurrentLocationAddressFromPlaceId:(NSString *)placeId :(locationAddressDetails)locationAddressDetail
{
    NSString *placeURL=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyBZokl35NK2BIpKpnFB97PIyvlSOKng9E0",placeId];
    NSURL *url = [NSURL URLWithString:[placeURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    dispatch_queue_t imageQueue = dispatch_queue_create("Place Queue",NULL);
    dispatch_async(imageQueue, ^{
        NSData *getData = [NSData dataWithContentsOfURL:url];
        NSString *strResponse;
        strResponse=[[NSString alloc]initWithData:getData encoding:NSStringEncodingConversionAllowLossy];
        if (!strResponse) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[strResponse dataUsingEncoding:NSUTF8StringEncoding]options:0 error:NULL];
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *locationDetails = [[NSMutableDictionary alloc]init];
                [locationDetails setValue:[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lat"] forKey:kLatitude];
                [locationDetails setValue:[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"] forKey:kLongitude];
                
               // [[UserManager shareUserManager]setLatitude:[NSString stringWithFormat:@"%@",[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lat"]]];
                //[[UserManager shareUserManager]setLongitude:[NSString stringWithFormat:@"%@",[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"]]];
                NSString  *localCoordinates=[NSString stringWithFormat:@"%.2f,%.2f",[[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lat"] floatValue],[[[[[jsonObject valueForKey:@"result"] valueForKey:@"geometry"] valueForKey:@"location"]valueForKey:@"lng"] floatValue]];
                if (localCoordinates != nil && [localCoordinates length] > 0)
                    
                {
                    locationAddressDetail(locationDetails);
                    [self getAddressFromLocationString:localCoordinates :^(NSMutableDictionary *dictionary){
                        [locationDetails setValue:[dictionary valueForKey:@"address"] forKey:@"currentAddress"];
                        locationAddressDetail(locationDetails);
                    }];
                }
            }
            
        });
        
    });
    return nil;
}





-(void)getAddressFromLocationString:(NSString *)_latlonStr :(currentAddress)currentLocationaddress
{
    [[YoReferAPI sharedAPI] getLocationDetailWithParma:_latlonStr CompletionHandler:^(NSDictionary *dictionary , NSError * error)
     {
         NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc]initWithCapacity:3];
          if ([[dictionary valueForKey:@"results"] count] > 0)
          {
              NSString *address=[[[dictionary valueForKey:@"results"] objectAtIndex:0] valueForKey:@"formatted_address"];
              [addressDictionary setValue:address forKey:@"address"];
              
              if ([[[[dictionary valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] count] > 7 )
              {
                  NSString *countryName = [[[[[dictionary valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] objectAtIndex:6] objectForKey:@"long_name"];
                  NSString *cityName = [[[[[dictionary valueForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] objectAtIndex:4] objectForKey:@"long_name"];
                  [addressDictionary setValue:countryName forKey:@"countryName"];
                  [addressDictionary setValue:cityName forKey:@"cityName"];
              }
              currentLocationaddress(addressDictionary);
          }
         
     }];
}
@end
