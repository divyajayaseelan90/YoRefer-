//
//  NIDropDown.h
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryType.h"

@class NIDropDown;
@protocol NIDropDownDelegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender;
- (void)getLoaction:(NSDictionary *)location;
@optional
- (void)getCategory:(CategoryType *)category;
- (void)getPersonContact:(NSDictionary *)contact;
- (void)getPlacesWithDetail:(NSDictionary *)detail;
- (void)getProductLocation:(NSDictionary *)location;
- (void)updateLocation;

@end

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>
{
    NSString *animationDirection;
    UIImageView *imgView;
}
@property (nonatomic, retain) id <NIDropDownDelegate> delegate;
@property (nonatomic, retain) NSString *animationDirection;
-(void)hideDropDown:(UIButton *)b;
- (id)showDropDown:(UIButton *)b:(CGFloat)height:(NSArray *)arr:(NSArray *)imgArr:(NSString *)direction type:(BOOL)isLocation;
@end
