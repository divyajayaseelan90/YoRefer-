//
//  MapViewController.h
//  YoRefer
//
//  Created by Selma D. Souza on 19/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "BaseViewController.h"
#import "NIDropDown.h"
#import <MapKit/MapKit.h>

@protocol MapRefer <NSObject>

- (void)getCurrentAddressDetail:(NSDictionary *)currentAddress;
- (void)LocationReferWithDetail:(NSMutableDictionary *)details;

@end

@interface MapViewController : BaseViewController

@property (nonatomic, strong) id<MapRefer>delegate;

- (instancetype)initWithResponse:(NSMutableArray *)response type:(NSString *)type isCurrentOffers:(BOOL)isCurrentOffers;

@end
