//
//  TMGoogleAnaliticsManager.h
//  Tmon
//
//  Created by jogun on 2014. 6. 24..
//  Copyright (c) 2014년 com.tmoncorp. All rights reserved.
//

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "GAITrackedViewController.h"
#import "GAITracker.h"

#define SHARE_TYPE @[@"d", @"c"]
#define PUSH_TYPE @[@"receive", @"open"]
#define PROMOTION_TYPE @[@"user", @"system"]
#define PROMOTION_KIND @[@"event_pop", @"home_banner", @"list_banner", @"drawer_banner"]

typedef NS_ENUM(int, enumDemensionForIndex)
{
    EnumDemensionForDeallist = 7,
    EnumDemensionForDetail = 8,
    EnumDemensionForDeallistSoho = 9,
    EnumDemensionForKeyword = 10,
    EnumDemensionForRegisterDate = 11,
    EnumDemensionForLogin = 12,
    EnumDemensionForAge = 13,
    EnumDemensionForGender = 14,
    EnumDemensionForVIPGrade = 15,
    EnumDemensionForLunchPath = 16,
    EnumDemensionForAlarm = 17,
    EnumDemensionForInstallDate = 18,
    EnumDemensionForUpdateDate = 19
};

typedef NS_ENUM(int, enumShareType)
{
    EnumShareDeal = 0,
    EnumShareCategory = 1
};

typedef NS_ENUM(int, enumShareCode)
{
    EnumShareCodeKakaoTalk = 1001,
    EnumShareCodeKakaoStory = 1002,
    EnumShareCodeFaceBook = 1003,
    EnumShareCodeLine = 1004,
    EnumShareCodeURL = 2001,
    EnumShareCodeSMS = 3001,
    EnumShareCodeOthers = 4001,
    EnumShareCodeCancel = 9001
};

typedef NS_ENUM(int, enumPushActionType)
{
    EnumPushActionRecieve = 0,
    EnumPushActionOpen = 1
};

typedef NS_ENUM(int, enumPromotionType)
{
    EnumPromotionUser = 0,
    EnumPromotionSystem = 1
};

typedef NS_ENUM(int, enumPromotionKind)
{
    EnumPromotionKindOfEventPop = 0,
    EnumPromotionKindOfHomeBanner = 1,
    EnumPromotionKindOfListBanner = 2,
    EnumPromotionKindOfDrawerBanner = 3
};


@interface TMGAManager : GAITrackedViewController

+ (TMGAManager *)sharedClient;

- (void)initialize;

// event
- (void)installEvent;
- (void)updateEvent;
- (void)locationEvent;
- (void)loginEvent:(BOOL)isAutoLogin;
- (void)logoutEvent;
- (void)shareEvent:(enumShareType)type code:(enumShareCode)code serail:(int)serial;
- (void)pokrEvent:(int)serial isPoke:(BOOL)isPoke;
- (void)cartEvent:(int)serial;
- (void)pushEvent:(enumPushActionType)actionType pushType:(NSString *)pushType serial:(int)serial;
- (void)promotionEvent:(enumPromotionType)promotionType promotionKind:(enumPromotionKind)promotionKind serial:(int)serial;
- (void)webviewEvent:(id)arg;

// pageview
- (void)homeDealListView:(NSString *)alias;
- (void)categoryDealListView:(NSString *)listname categorySrl:(int)categorySrl;
- (void)localDealListView:(int)areaId;
- (void)sohoShopListView:(NSString *)alias;
- (void)sohoDealListView:(int)categorySrl partnerSrl:(int)partnerSrl;
- (void)dealDetailView:(int)dealSrl categorySrl:(int)categorySrl;

- (void)webviewEcommerceView:(NSString *)tranId affiliation:(NSString *)affiliation revenue:(NSNumber *)revenue tax:(NSNumber *)tax shipping:(NSNumber *)shipping currency:(NSString *)currency;
- (void)webviewEcommerceViewById:(NSString *)tranId name:(NSString *)name sku:(NSString *)sku category:(NSString *)category price:(NSNumber *)price quantity:(NSNumber *)quantity currency:(NSString *)currency;
- (void)webviewPageView:(NSString *)screenName;
- (void)webviewPageView:(NSString *)screenName jsonText:(NSString *)jsonText;



@end
