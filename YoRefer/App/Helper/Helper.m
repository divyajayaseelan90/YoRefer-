//
//  Helper.m
//  YoRefer
//
//  Created by Sunilkumar Basappa on 08/10/15.
//  Copyright © 2015 UDVI. All rights reserved.
//

#import "Helper.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "CategoryType.h"
#import "NBPhoneMetaDataGenerator.h"
#import "NBPhoneNumberUtil.h"
#import "NIDropDown.h"
#import "Constant.h"
#import "YoReferUserDefaults.h"

@implementation Helper


+ (Helper *)shareHelper
{
    
    static Helper *_shareHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _shareHelper = [[Helper alloc]init];
        
    });
    
    return _shareHelper;
    
}

#pragma mark - Error

- (BOOL)validateLoginAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params
{
    
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    
    if ([params objectForKey:@"number"] == nil || [[params objectForKey:@"number"] length] <=0)
    {
        [errorMessage addObject:@"Enter Email/Phone No"];
    }
    
    if ([params objectForKey:@"password"] == nil || [[params objectForKey:@"password"] length] <=0)
    {
        [errorMessage addObject:@"Enter password"];
    }
    
    *error = errorMessage;
    
    return [errorMessage count] > 0 ? NO : YES;
    
}


#pragma mark - add contact

- (BOOL)validateAddContactAllEnteriesWithError:(NSArray **)error contacts:(NSMutableDictionary *)contacts isMessage:(BOOL)isMessage
{
    
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    
    if ([contacts objectForKey:@"firstname"] == nil || [[contacts objectForKey:@"firstname"] length] <=0)
    {
        [errorMessage addObject:@"Enter name"];
    }
    
    if ([contacts objectForKey:@"emailphonenumber"] == nil || [[contacts objectForKey:@"emailphonenumber"] length] <=0)
    {
        [errorMessage addObject:(isMessage)?@"Enter phonenumber":@"Enter email"];
    }
    
    *error = errorMessage;
    
    return [errorMessage count] > 0 ? NO : YES;
    
}


- (BOOL)validateSignUpAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params
{
    
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    
        
    if ([params objectForKey:@"name"] == nil || [[params objectForKey:@"name"] length] <=0)
    {
        [errorMessage addObject:@"Enter name"];
    }
    
    /*
    if ([params objectForKey:@"emailId"] == nil || [[params objectForKey:@"emailId"] length] <=0)
    {
        [errorMessage addObject:@"Enter emailid"];
    }
    */
    
    if ([params objectForKey:@"number"] == nil || [[params objectForKey:@"number"] length] <=0)
    {
        [errorMessage addObject:@"Enter number"];
    }
    
    if ([params objectForKey:@"password"] == nil || [[params objectForKey:@"password"] length] <=0)
    {
        [errorMessage addObject:@"Enter password"];
    }
    if ([self webValidationWithWeb:[params objectForKey:@"website"]])
    {
        [errorMessage addObject:@"Enter Valid Web Site"];
    }
    
    
    
    *error = errorMessage;
    
    return [errorMessage count] > 0 ? NO : YES;
    
    
}

- (BOOL)validateForgotPasswordAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params
{
    
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    
    if ([[params objectForKey:@"password"] length] > 0 || [[params objectForKey:@"password"] length] > 0)
    {
        
    }else
    {
        [errorMessage addObject:@"Enter Password"];
    }
    
    
    *error = errorMessage;
    
    return [errorMessage count] > 0 ? NO : YES;
    
}


- (BOOL)validateOTPAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params
{
    
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    
    if ([params objectForKey:@"otp"] == nil || [[params objectForKey:@"otp"] length] <=0)
    {
        [errorMessage addObject:@"Enter OTP"];
    }
    
    if ([params objectForKey:@"password"] == nil || [[params objectForKey:@"password"] length] <=0)
    {
        [errorMessage addObject:@"Enter password"];
    }
    
    *error = errorMessage;
    
    return [errorMessage count] > 0 ? NO : YES;
    
    
}


- (BOOL)validateChangePwdAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params
{
    
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    
    if ([params objectForKey:@"oldPassword"] == nil || [[params objectForKey:@"oldPassword"] length] <=0)
    {
        [errorMessage addObject:@"Enter Old Password"];
    }
    
    if ([params objectForKey:@"newPassword"] == nil || [[params objectForKey:@"newPassword"] length] <=0)
    {
        [errorMessage addObject:@"Enter Change Password"];
    }
    
    if ([params objectForKey:@"confirmPassword"] == nil || [[params objectForKey:@"confirmPassword"] length] <=0)
    {
        [errorMessage addObject:@"Enter Confirm Password"];
    }
    
    *error = errorMessage;
    
    return [errorMessage count] > 0 ? NO : YES;
    
}

- (BOOL)validateAskAllEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params
{
    
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    
    if ([params objectForKey:@"querymeessage"] == nil || [[params objectForKey:@"querymeessage"] length] <=0)
        
    {
        [errorMessage addObject:@"Enter message"];
    }
    
    if ([[params objectForKey:@"querymeessage"] isEqualToString:@"Type what you are looking for?"])
    {
        
    }
    
    if ([params objectForKey:@"category"] == nil || [[params objectForKey:@"category"] length] <= 0)
    {
        [errorMessage addObject:@"Select category"];
    }
    
    if ([params objectForKey:@"categorytype"] == nil || [[params objectForKey:@"categorytype"] length] <=0)
    {
        [errorMessage addObject:@"Select category type"];
    }
    
    if ([params objectForKey:@"address"] == nil || [[params objectForKey:@"address"] length] <=0)
    {
        [errorMessage addObject:@"Enter address"];
    }
    
    *error = errorMessage;
    
    return [errorMessage count] > 0 ? NO : YES;
    
}


#pragma mark - Refer channel

- (BOOL)validateReferChannelEnteriesWithError:(NSArray **)error params:(NSMutableDictionary *)params
{
    NSMutableArray *errorMessage = [[NSMutableArray alloc]init];
    if ([[params objectForKey:@"web"] boolValue])
    {
        if ([params objectForKey:@"name"] == nil || [[params objectForKey:@"name"] length] <=0)
        {
            [errorMessage addObject:@"Please enter a valid name"];
        }
        /*
        if ([params objectForKey:@"website"] == nil || [[params objectForKey:@"website"] length] <=0)
        {
            [errorMessage addObject:@"Please enter a website name"];
        }
        */
    }else
    {
        if (([params objectForKey:@"location"] == nil ||   [[params objectForKey:@"location"] length] <=0) && ![[params valueForKey:@"categorytype"] isEqualToString:@"service"] && ![[params valueForKey:@"categorytype"] isEqualToString:kProduct])
        {
            [errorMessage addObject:@"Enter address"];
        }
        if (([params objectForKey:@"name"] == nil || [[params objectForKey:@"name"] length] <=0))
        {
            [errorMessage addObject:@"Please enter a valid name"];
        }
        if ([params objectForKey:@"location"] == nil || [[params objectForKey:@"location"] length] <=0)
        {
            if ([[params valueForKey:kCategorytype] isEqualToString:kPlace])
            {
                [errorMessage addObject:@"Enter location"];
            }
            
        }
        /*
        if (![self webValidationWithWeb:[params objectForKey:@"website"]] && [params objectForKey:@"website"] != nil && [[params objectForKey:@"website"] length] >0 && [[params valueForKey:kNewRefer] boolValue] && ![[params valueForKey:kCategorytype] isEqualToString:kService])
        {
            [errorMessage addObject:@"Please Enter Valid WebSite"];
        }
         */
    }
    *error = errorMessage;
    return [errorMessage count] > 0 ? NO : YES;
}

- (NSString *)getErrorStringFromErrorDescription:(NSArray *)error
{
    
    __block NSString *errorString = @"";
    
    [error enumerateObjectsUsingBlock:^(id obj,NSUInteger idex,BOOL *stop){
        
        if ([obj isKindOfClass:[NSString class]])
        {
            errorString = [errorString stringByAppendingFormat:@"- %@\n",(NSString *)obj];
        }
        
    }];
    
    return NSLocalizedString(errorString, @"");
    
}


#pragma mark - Email Validation

- (BOOL)emailValidationWithEmail:(NSString *)emailString
{
    if (emailString != nil)
    {
        NSString *emailRegEx = @"(?:[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-"
        @"zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        return [regExPredicate evaluateWithObject:emailString];
    }
    
    return NO;
    
}

#pragma mark - Web Url Validation

- (BOOL)webValidationWithWeb:(NSString *)WebString
{
    NSURL *candidateURL = [NSURL URLWithString:WebString];
    if (candidateURL && candidateURL.scheme && candidateURL.host)
    {
        return YES;
    }else
    {
        return NO;
    }
//    NSString *urlRegEx =
//    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
//    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    //[urlTest evaluateWithObject:WebString];
    return NO;
}




#pragma mark - Phone number validation

- (NSString *)getExactPhoneNumberWithNumber:(NSString *)phoneNumber
{
    //[self getLocalCountryCode]
    
    NSString *extractPhoneNo = nil;
    if ([phoneNumber rangeOfString:@"+"].location!=NSNotFound)
        extractPhoneNo = [NSString stringWithFormat:@"%@%@",[self getCountryCodeNumber:phoneNumber],[self getStrippedNumber:[self extractPhoneNumber:phoneNumber]]];
    
    else
        extractPhoneNo = [NSString stringWithFormat:@"%@",[self getStrippedNumber:[self extractPhoneNumber:phoneNumber]]];
    return extractPhoneNo;
    
}

-(NSString *)getCountryCodeNumber :(NSString *)_number
{
    
    NSString *cntryCode;
    
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    {
        NSError *error = nil;
        //NBPhoneNumber *phoneNumberUS = [phoneUtil parse:_number defaultRegion:@"" error:&error];
        if (error) {
            NSLog(@"err [%@]", [error localizedDescription]);
        }
        
        cntryCode =[NSString stringWithFormat:@"%@",[phoneUtil extractCountryCode:_number nationalNumber:nil]];
        
        if ([cntryCode length]!=0)
            cntryCode=[@"+" stringByAppendingString:cntryCode];
        
        return cntryCode;
    }
    
    return @"";
}


-(NSString *)extractPhoneNumber :(NSString *)_number
{
    
    NSString *cntryCode=@"";
    NBPhoneNumberUtil *phoneUtil = [NBPhoneNumberUtil sharedInstance];
    
    {
        NSError *error = nil;
        //NBPhoneNumber *phoneNumberUS = [phoneUtil parse:_number defaultRegion:@"" error:&error];
        if (error) {
            NSLog(@"err [%@]", [error localizedDescription]);
        }
        
        cntryCode =[NSString stringWithFormat:@"%@",[phoneUtil extractCountryCode:_number nationalNumber:nil]];
        
        if ([cntryCode length]!=0)
            cntryCode=[@"+" stringByAppendingString:cntryCode];
        
        cntryCode =[_number stringByReplacingOccurrencesOfString:cntryCode withString:@""];
        
        return cntryCode;
        
    }
    return @"";
}


-(NSString *)getStrippedNumber:(NSString *)_num
{
    NSString * number = _num;
    NSString * strippedNumber = [number stringByReplacingOccurrencesOfString:@"[^0-9]"
                                                                  withString:@""
                                                                     options:NSRegularExpressionSearch
                                                                       range:NSMakeRange(0, [number length])];
    
    return strippedNumber;
}


- (NSString *)getLocalCountryCode
{
    CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = network_Info.subscriberCellularProvider;
    NSString *cc = [carrier isoCountryCode];
    if ([cc length]==0) {
        cc=@"in";
     }
    return [self getPhoneCode:cc];

}


- (NSString *)getPhoneCode:(NSString *)countrycode
{
    
    NSString *jsonString = @"{\"BD\": \"880\", \"BE\": \"32\", \"BF\": \"226\", \"BG\": \"359\", \"BA\": \"387\", \"BB\": \"+1-246\", \"WF\": \"681\", \"BL\": \"590\", \"BM\": \"+1-441\", \"BN\": \"673\", \"BO\": \"591\", \"BH\": \"973\", \"BI\": \"257\", \"BJ\": \"229\", \"BT\": \"975\", \"JM\": \"+1-876\", \"BV\": \"\", \"BW\": \"267\", \"WS\": \"685\", \"BQ\": \"599\", \"BR\": \"55\", \"BS\": \"+1-242\", \"JE\": \"+44-1534\", \"BY\": \"375\", \"BZ\": \"501\", \"RU\": \"7\", \"RW\": \"250\", \"RS\": \"381\", \"TL\": \"670\", \"RE\": \"262\", \"TM\": \"993\", \"TJ\": \"992\", \"RO\": \"40\", \"TK\": \"690\", \"GW\": \"245\", \"GU\": \"+1-671\", \"GT\": \"502\", \"GS\": \"\", \"GR\": \"30\", \"GQ\": \"240\", \"GP\": \"590\", \"JP\": \"81\", \"GY\": \"592\", \"GG\": \"+44-1481\", \"GF\": \"594\", \"GE\": \"995\", \"GD\": \"+1-473\", \"GB\": \"44\", \"GA\": \"241\", \"SV\": \"503\", \"GN\": \"224\", \"GM\": \"220\", \"GL\": \"299\", \"GI\": \"350\", \"GH\": \"233\", \"OM\": \"968\", \"TN\": \"216\", \"JO\": \"962\", \"HR\": \"385\", \"HT\": \"509\", \"HU\": \"36\", \"HK\": \"852\", \"HN\": \"504\", \"HM\": \" \", \"VE\": \"58\", \"PR\": \"+1-787 and 1-939\", \"PS\": \"970\", \"PW\": \"680\", \"PT\": \"351\", \"SJ\": \"47\", \"PY\": \"595\", \"IQ\": \"964\", \"PA\": \"507\", \"PF\": \"689\", \"PG\": \"675\", \"PE\": \"51\", \"PK\": \"92\", \"PH\": \"63\", \"PN\": \"870\", \"PL\": \"48\", \"PM\": \"508\", \"ZM\": \"260\", \"EH\": \"212\", \"EE\": \"372\", \"EG\": \"20\", \"ZA\": \"27\", \"EC\": \"593\", \"IT\": \"39\", \"VN\": \"84\", \"SB\": \"677\", \"ET\": \"251\", \"SO\": \"252\", \"ZW\": \"263\", \"SA\": \"966\", \"ES\": \"34\", \"ER\": \"291\", \"ME\": \"382\", \"MD\": \"373\", \"MG\": \"261\", \"MF\": \"590\", \"MA\": \"212\", \"MC\": \"377\", \"UZ\": \"998\", \"MM\": \"95\", \"ML\": \"223\", \"MO\": \"853\", \"MN\": \"976\", \"MH\": \"692\", \"MK\": \"389\", \"MU\": \"230\", \"MT\": \"356\", \"MW\": \"265\", \"MV\": \"960\", \"MQ\": \"596\", \"MP\": \"+1-670\", \"MS\": \"+1-664\", \"MR\": \"222\", \"IM\": \"+44-1624\", \"UG\": \"256\", \"TZ\": \"255\", \"MY\": \"60\", \"MX\": \"52\", \"IL\": \"972\", \"FR\": \"33\", \"IO\": \"246\", \"SH\": \"290\", \"FI\": \"358\", \"FJ\": \"679\", \"FK\": \"500\", \"FM\": \"691\", \"FO\": \"298\", \"NI\": \"505\", \"NL\": \"31\", \"NO\": \"47\", \"NA\": \"264\", \"VU\": \"678\", \"NC\": \"687\", \"NE\": \"227\", \"NF\": \"672\", \"NG\": \"234\", \"NZ\": \"64\", \"NP\": \"977\", \"NR\": \"674\", \"NU\": \"683\", \"CK\": \"682\", \"XK\": \"\", \"CI\": \"225\", \"CH\": \"41\", \"CO\": \"57\", \"CN\": \"86\", \"CM\": \"237\", \"CL\": \"56\", \"CC\": \"61\", \"CA\": \"1\", \"CG\": \"242\", \"CF\": \"236\", \"CD\": \"243\", \"CZ\": \"420\", \"CY\": \"357\", \"CX\": \"61\", \"CR\": \"506\", \"CW\": \"599\", \"CV\": \"238\", \"CU\": \"53\", \"SZ\": \"268\", \"SY\": \"963\", \"SX\": \"599\", \"KG\": \"996\", \"KE\": \"254\", \"SS\": \"211\", \"SR\": \"597\", \"KI\": \"686\", \"KH\": \"855\", \"KN\": \"+1-869\", \"KM\": \"269\", \"ST\": \"239\", \"SK\": \"421\", \"KR\": \"82\", \"SI\": \"386\", \"KP\": \"850\", \"KW\": \"965\", \"SN\": \"221\", \"SM\": \"378\", \"SL\": \"232\", \"SC\": \"248\", \"KZ\": \"7\", \"KY\": \"+1-345\", \"SG\": \"65\", \"SE\": \"46\", \"SD\": \"249\", \"DO\": \"+1-809 and 1-829\", \"DM\": \"+1-767\", \"DJ\": \"253\", \"DK\": \"45\", \"VG\": \"+1-284\", \"DE\": \"49\", \"YE\": \"967\", \"DZ\": \"213\", \"US\": \"1\", \"UY\": \"598\", \"YT\": \"262\", \"UM\": \"1\", \"LB\": \"961\", \"LC\": \"+1-758\", \"LA\": \"856\", \"TV\": \"688\", \"TW\": \"886\", \"TT\": \"+1-868\", \"TR\": \"90\", \"LK\": \"94\", \"LI\": \"423\", \"LV\": \"371\", \"TO\": \"676\", \"LT\": \"370\", \"LU\": \"352\", \"LR\": \"231\", \"LS\": \"266\", \"TH\": \"66\", \"TF\": \"\", \"TG\": \"228\", \"TD\": \"235\", \"TC\": \"+1-649\", \"LY\": \"218\", \"VA\": \"379\", \"VC\": \"+1-784\", \"AE\": \"971\", \"AD\": \"376\", \"AG\": \"+1-268\", \"AF\": \"93\", \"AI\": \"+1-264\", \"VI\": \"+1-340\", \"IS\": \"354\", \"IR\": \"98\", \"AM\": \"374\", \"AL\": \"355\", \"AO\": \"244\", \"AQ\": \"\", \"AS\": \"+1-684\", \"AR\": \"54\", \"AU\": \"61\", \"AT\": \"43\", \"AW\": \"297\", \"IN\": \"91\", \"AX\": \"+358-18\", \"AZ\": \"994\", \"IE\": \"353\", \"ID\": \"62\", \"UA\": \"380\", \"QA\": \"974\", \"MZ\": \"258\"}";
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *getPhoneCodeDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSString *phCode;
    
    if ([getPhoneCodeDic isKindOfClass:[NSDictionary class]]) {
        
        phCode=[getPhoneCodeDic valueForKey:[countrycode uppercaseString]];
        
    }
    phCode=[self getStrippedNumber:phCode];
    
    phCode=[@"+"stringByAppendingString:phCode];
    
    return phCode;
    
}


#pragma mark-scaleImage
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - currentTimeWithMilliSecound
-(NSString *)currentTimeWithMilliSecound
{
    NSDate *date = [NSDate date];
    return [NSString stringWithFormat:@"%lli",[@(floor([date timeIntervalSince1970] * 1000)) longLongValue]];
}


#pragma mark - Get AllContracts
-(NSMutableArray *)getAllContacts
{
    NSMutableArray *contactList = [[NSMutableArray alloc]init];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = addressBookRef;
            NSLog(@"%@",addressBook);
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        CFIndex count = ABAddressBookGetPersonCount(addressBookRef);
        for (int i = 0; i < count; i++)
        {
            NSMutableDictionary *contact = [NSMutableDictionary dictionary];
            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
            ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(ref, kABPersonLastNameProperty));
            firstName = (firstName != nil)?firstName:@"";
            lastName  = (lastName != nil)?lastName:@"";
            if ((firstName || lastName))
            {
                NSArray *phoneNumbersRaw = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phones));
                NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithCapacity:phoneNumbersRaw.count];
                for (NSString *number in phoneNumbersRaw)
                {
                    //phone number must only contain numbers
                    NSMutableString *strippedNumber = [NSMutableString string];
                    
                    NSScanner *scanner = [NSScanner scannerWithString:number];
                    NSCharacterSet *numbers = [NSCharacterSet
                                               characterSetWithCharactersInString:@"0123456789"];
                    while (![scanner isAtEnd]) {
                        NSString *buffer;
                        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
                            [strippedNumber appendString:buffer];
                            
                        } else {
                            [scanner setScanLocation:([scanner scanLocation] + 1)];
                        }
                    }
                    if (strippedNumber.length >0) {
                        [phoneNumbers addObject:[NSString stringWithString:strippedNumber]];
                    }
                }
                NSString *email = @"";
                ABMultiValueRef emails = ABRecordCopyValue(ref, kABPersonEmailProperty);
                if (ABMultiValueGetCount(emails) > 0) {
                    email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, 0));
                }
                if ([[Helper shareHelper] emailValidationWithEmail:email]) {
                    [contact setObject:email forKey:@"Email"];
                }
                CFRelease(emails);
                
                if (!firstName) {
                    firstName = @"";
                }
                [contact setObject:firstName forKey:@"Firstname"];
                
                if (!lastName) {
                    lastName = @"";
                }
                [contact setObject:lastName forKey:@"Lastname"];
                [contact setObject:[NSArray arrayWithArray:phoneNumbers] forKey:@"Phonenumbers"];
                [contact setObject:[NSString stringWithFormat:@"%d",ABRecordGetRecordID(ref)] forKey:@"ABID"];
                if ([[contact valueForKey:@"Phonenumbers"] count] > 0 || [[contact valueForKey:@"Email"] length] > 0)
                        [contactList addObject:contact];
               
            }
            CFRelease(phones);
            CFRelease(ref);
        }
        CFRelease(allPeople);
    }
    else {
        
    }
    return contactList;
}

#pragma mark - GetRandomEntityId

- (NSString *)getRandomEntityId
{
    NSString *letters= @"abcdOPQRSTUVWXYZ0123456789";
    NSString *entityId = [self randomStringWithLength:20 letters:letters];
    return entityId;
}

-(NSString *)randomStringWithLength: (int) len letters:(NSString *)letters
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++)
    {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}

- (void)isReferChannel:(BOOL)isReferChannel
{
    [[YoReferUserDefaults shareUserDefaluts] setValue:[NSNumber numberWithBool:isReferChannel] forKey:@"isReferChannel"];
}

- (BOOL)isReferChannelStatus
{
    return [[[YoReferUserDefaults shareUserDefaluts] valueForKey:@"isReferChannel"] boolValue];
}

@end
