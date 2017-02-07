//
//  CategoriesView.h
//  YoRefer
//
//  Created by Bhaskar C M on 11/2/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryView <NSObject>

@optional
- (void)pushToReferPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)pushToEntityPageWithIndexPath:(NSIndexPath *)indexPath;
- (void)responseEntityPageWithDetails:(NSDictionary *)details;
- (void)responseReferPageWithDetails:(NSDictionary *)details;
- (void)responseMapPageWithDetails:(NSDictionary *)details;
- (void)responseSelfPageWithDetails:(NSDictionary *)details userType:(NSInteger)userType;

@end

@interface CategoriesView : UIView

- (instancetype)initWithViewFrame:(CGRect)frame categoryList:(NSDictionary *)categoryList delegate:(id<CategoryView>)delegate isResponse:(BOOL)isResponse;

@property (nonatomic, weak) id <CategoryView>delegate;

@end
