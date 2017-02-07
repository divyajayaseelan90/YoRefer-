//
//  SettingsTableViewCell.h
//  YoRefer
//
//  Created by Sunilkumar Basappa on 11/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
    SettingsProfile,
    ChangePassword,
    NearByLocationServices,
    ReferChannels,
    TermsAndConditions,
    PrivacyPolicy,
    AboutUs,
    YoreferVersion,
    SendFeedBack,
    SettingsLogOut
    
}settingsType;


@protocol settings <NSObject>

- (void)pushSettingType:(settingsType)settingsType;


@end

@interface SettingsTableViewCell : UITableViewCell

- (instancetype)initWihtIndexPath:(NSIndexPath *)indexPath delegate:(id<settings>)delegate;

@property (nonatomic, weak) id<settings>delegate;

@end

extern NSString * const kSettingsIdentifier;