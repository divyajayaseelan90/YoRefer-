//
//  ContactListTableViewCell.h
//  YoRefer
//
//  Created by Bhaskar C M on 10/21/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContactList <NSObject>

@optional

- (void)contactListWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ContactListTableViewCell : UITableViewCell

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ContactList>)delegate response:(NSDictionary *)response;


@property (nonatomic, weak) id <ContactList>delegate;

@end

extern NSString * const kContactIdentifier;