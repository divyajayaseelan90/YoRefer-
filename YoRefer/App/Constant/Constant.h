//
//  Constant.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/7/15.
//  Copyright © 2015 UDVI. All rights reserved.
//


#import "YoReferUserDefaults.h"
#define mapImage        [UIImage imageNamed:@"icon_map.png"]
#define webImage        [UIImage imageNamed:@"icon_featured_website.png"]
#define homeArrow       [UIImage imageNamed:@"icon_home_arrow.png"]
#define profilePic      [UIImage imageNamed:@"icon_profile.png"]
#define groupPic        [UIImage imageNamed:@"icon_groupprofile.png"]
#define homeRefer       [UIImage imageNamed:@"icon_home_refer.png"]
#define homeAsk         [UIImage imageNamed:@"icon_home_ask.png"]
#define downarraow      [UIImage imageNamed:@"icon_down.png"]
#define whatsappImg     [UIImage imageNamed:@"icon_whatsapp.png"]
#define facebookImg     [UIImage imageNamed:@"icon_facebook.png"]
#define twitterImg      [UIImage imageNamed:@"icon_twitter.png"]
#define placeImg        [UIImage imageNamed:@"icon_place.png"]
#define productImg      [UIImage imageNamed:@"icon_product.png"]
#define webLinkImg      [UIImage imageNamed:@"icon_weblink.png"]
#define serviceImg      [UIImage imageNamed:@"icon_service.png"]
#define noPhotoImg      [UIImage imageNamed:@"icon_nophoto.png"]
#define mobileImg       [UIImage imageNamed:@"icon_featured_mobile.png"]
#define websiteImg      [UIImage imageNamed:@"icon_featured_website.png"]
#define emailImg        [UIImage imageNamed:@"icon_email_entity.png"]
#define crossBtnImg     [UIImage imageNamed:@"cross.png"]
#define locationPin     [UIImage imageNamed:@"icon_location_pin.png"]
#define currentlocation [UIImage imageNamed:@"icon_current.png"]
#define mapPin          [UIImage imageNamed:@"icon_pin.png"]
#define rightArrowImg   [UIImage imageNamed:@"icon_rightArrow.png"]
#define popupDown       [UIImage imageNamed:@"icon_popup_downt-01.png"]
#define downArrowImg    [UIImage imageNamed:@"icon_downarrow.png"]
#define crossIconImg    [UIImage imageNamed:@"icon_cross.png"]
#define cameraImg       [UIImage imageNamed:@"icon_refercamera.png"]
#define disableDownImg  [UIImage imageNamed:@"icon_downarrow_gray.png"]
#define leftIconImg     [UIImage imageNamed:@"icon_left.png"]
#define rightIconImg    [UIImage imageNamed:@"icon_right.png"]
#define referIconImg    [UIImage imageNamed:@"icon_refer.png"]




static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION     = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION     = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT    = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT   = 162;

static const  NSString * limit        = @"5";

#import "SWRevealViewController.h"
#import "Configuration.h"
#import "YoReferAPI.h"
#import "UserManager.h"
#import "Utility.h"
#import "CoreData.h"
#import "NIDropDown.h"
#import "LocationManager.h"
#import "Helper.h"
#import "LazyLoading.h"
#import "DocumentDirectory.h"
#import "YoReferAPI.h"
#import "Utility.h"
#import "KeyboardHelper.h"
#import <AddressBookUI/AddressBookUI.h>

#define kCategorytype                       @"categorytype"
#define kCategory                           @"category"
#define kEntity                             @"entity"
#define kCategoryid                         @"categoryid"
#define kName                               @"name"
#define kCity                               @"city"
#define kAddress                            @"address"
#define kLocality                           @"locality"
#define kLocation                           @"location"
#define kPosition                           @"position"
#define kType                               @"type"
#define kFoursquareCategoryId               @"foursquareCategoryId"
#define kLatitude                           @"latitude"
#define kLongitude                          @"longitude"
#define kNewRefer                           @"newrefer"
#define kIsEntiyd                           @"isentiyd"
#define kPhone                              @"phone"
#define kDp                                 @"dp"
#define kMediaId                            @"mediaid"
#define kReferimage                         @"referimage"
#define kWebSite                            @"website"
#define kEmail                              @"email"
#define kEntityId                           @"entityId"
#define kRefer                              @"refer"
#define kAsk                                @"ask"
#define kType                               @"type"
#define kWeb                                @"web"
#define kWeblink                            @"weblink"
#define kMessage                            @"message"
#define kProduct                            @"product"
#define kService                            @"service"
#define kPurchasedFrom                      @"purchasedFrom"
#define kDetail                             @"detail"
#define kLocality                           @"locality"
#define kFromWhere                          @"fromwhere"
#define kIsEntity                           @"isentity"
#define kPlace                              @"place"
#define kAskId                              @"askid"
#define kNumber                             @"number"
#define kReferPhone                         @"referphone"
#define kReferName                          @"refername"
#define kIsAsk                              @"isask"
#define kContactCategory                    @"contactcategory"
#define kReferCount                         @"refercount"
#define kMediaCount                         @"mediacount"
#define kMediaLinks                         @"medialinks"
#define kGuest                              @"guest"
#define kRefers                             @"refers"
#define kFeedsCount                         @"feedscount"
#define kAskCount                           @"askcount"
#define kFriendsCount                       @"friendscount"
#define kPointsEarned                       @"pointsearned"
#define kPointsBurnt                        @"pointsburnt"
#define kFrom                               @"from"
#define kToUser                             @"touser"
#define kUser                               @"user"
#define kConnections                        @"connections"
#define kImage                              @"image"
#define kYPostion                           @"yPostion"
#define kLimit                              @"limit"
#define kBefore                             @"before"
#define kWhatsapp                           @"whatsapp"
#define kFacebook                           @"facebook"
#define kTwitter                            @"twitter"
#define kCityState                          @"cityState"









