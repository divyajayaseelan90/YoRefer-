//
//  ReferNowTableViewCell.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/15/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YoReferMedia.h"
#import "NIDropDown.h"

typedef enum
{
    ReferLocations,
    ReferCategoryType,
    ReferCategories,
    ReferName,
    ReferMessage,
    ReferFromWhere,
    ReferAddress,
    ReferPhoneAndWebSite,
    ReferImage,
    Phone,
    Website,
    ReferEmailID,
    ReferNowcategory
}ReferNowType;

typedef enum
{
    ReferPlaces = 200,
    ReferProduct,
    ReferServices
    
}Categories;

@protocol referNowTableViewCell <NSObject>

- (void)enableLocationWithButton:(UIButton *)button;
- (void)locationSearchWithButton:(UIButton *)button;
- (void)TextFieldWithAnimation:(BOOL)animation textField:(UITextField *)textField;
- (void)TextViewdWithAnimation:(BOOL)animation textView:(UITextView *)textView;
- (void)textFieldshouldChangeCharactersWithTextField:(UITextField *)textField string:(NSString *)string;
- (void)textWithMessageLocation:(NSString *)messageLocation referType:(ReferNowType)referType;
- (void)placeWithSpuerView:(UIView *)supverView;
- (void)productWithSpuerView:(UIView *)supverView;
- (void)serviceWithSpuerView:(UIView *)supverView;
- (void)webWithSpuerView:(UIView *)supverView;
- (void)categoriesWithButton:(UIButton *)button;
- (void)placeSearchWithTextField:(UITextField *)textField;
- (void)pushToMapPage;
- (void)phoneWesiteWithText:(NSString *)text referRtype:(ReferNowType)referType;
- (void)newImage;
- (void)viewImageWithImage:(UIImage *)image defaultImage:(BOOL)isDefaultImage;
- (void)serviceNameWithButton:(UIButton *)button;
- (void)clearTextWithTextFiled:(UITextField *)textField;
- (void)webLink;
@end

@interface ReferNowTableViewCell : UITableViewCell<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, weak) id <referNowTableViewCell>delegate;
@property (nonatomic, strong) NIDropDown    * nIDropDown;
@property (strong, nonatomic) UIView  *dropDownViews;
@property (strong, nonatomic) UITextView *websiteShortenUrlTxtField;



- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<referNowTableViewCell>)delegate referDetail:(NSMutableDictionary *)referDetail;

@end

extern NSString * const kReferNowIdentifier;
