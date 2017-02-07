//
//  QueryTableViewCell.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/14/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryType.h"
#import "NIDropDown.h"


typedef enum {
    QueryLocation,
    QueryCategoryType,
    QueryCategory,
    QueryMessage,
    QueryAsk,
}QueryType;

typedef enum {
    
    Places = 200,
    Product,
    Services
    
}categories;

@protocol queryTableViewCell <NSObject>

- (void)TextFieldWithAnimation:(BOOL)animation textField:(UITextField *)textField;
- (void)TextViewdWithAnimation:(BOOL)animation textView:(UITextView *)textView;
- (void)textfieldshouldChangeCharactersWithTextField:(UITextField *)textField string:(NSString *)string;
- (void)locationSearchWithButton:(UIButton *)button;
- (void)placeWithSpuerView:(UIView *)supverView;
- (void)productWithSpuerView:(UIView *)supverView;
- (void)serviceWithSpuerView:(UIView *)supverView;
- (void)categoriesWithButton:(UIButton *)button;
- (void)queryWithMessage:(NSString *)queryMessage;
- (void)enableLocationWithButton:(UIButton *)button;
- (void)postQuery;
@end

@interface QueryTableViewCell : UITableViewCell<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, weak) id <queryTableViewCell>delegate;

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<queryTableViewCell>)delegate queryDetail:(NSMutableDictionary *)queryDetail;

@end

extern NSString * const kQueryReuseIdentifier;