//
//  LocationManager.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 10/16/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^locationSearchDetails) (NSMutableArray *array);
typedef void (^locationAddressDetails)(NSMutableDictionary *array);
typedef void (^currentAddress)(NSMutableDictionary *dictionary);

@protocol LocationManger <NSObject>
- (void)getCurrentLocationWithAddress:(NSDictionary *)address latitude:(NSString *)latitude
                             logitude:(NSString *)logitude;
@end

@interface LocationManager : NSObject <CLLocationManagerDelegate>
@property(nonatomic,    strong)     CLLocationManager   *locationManager;
@property(nonatomic,    strong)     CLLocation          *currentLocation;
@property(nonatomic,    weak)       id<LocationManger>  delegate;
- (instancetype)initWithDelegate:(id<LocationManger>)delegate;
+ (LocationManager *)shareLocationManager;
-(BOOL)CheckForLocationService;
- (void)getCurrentLocation;
- (void)searchCityWithName:(NSString *)name :(locationSearchDetails)locationdetails;
- (NSMutableDictionary *)getCurrentLocationAddressFromPlaceId:(NSString *)placeId :(locationAddressDetails)locationAddressDetail;
-(void)getAddressFromLocationString:(NSString *)_latlonStr :(currentAddress)currentLocationaddress;
@end
