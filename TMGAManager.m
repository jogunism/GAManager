//
//  TMGoogleAnaliticsManager.m
//  Tmon
//
//  Created by jogun on 2014. 6. 24..
//  Copyright (c) 2014년 com.tmoncorp. All rights reserved.
//

#import "TMGAManager.h"
#ifdef DEBUG
#define TRACKING_ID @"UA-43440931-3"
#else
#define TRACKING_ID @"UA-10587421-2"
#endif

@implementation TMGAManager

#pragma mark - lifecycle

+ (TMGAManager *)sharedClient
{
    static TMGAManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TMGAManager alloc] init];
    });

    return _sharedClient;
}

- (void)initialize
{
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];              // automatically send uncaught exceptions
    [[GAI sharedInstance] setDispatchInterval:20];                      // dispatch interval
    [[GAI sharedInstance] trackerWithTrackingId:TRACKING_ID];           // initailize
#ifdef DEBUG
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];    // Logger level
#else
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
#endif
}


#pragma mark - private method

- (void)initializeTracker
{
    if(!self.tracker)
        self.tracker = [[GAI sharedInstance] defaultTracker];
}

- (void)sendTracker
{
    [self sendTracker:nil];
}

- (void)sendTracker:(NSDictionary *)event
{
    if(!self.tracker)
        return;

    if(event)
        [self.tracker send:event];
    else
        [self.tracker send:[[GAIDictionaryBuilder createAppView] build]];

    // demension clear
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallist] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDetail] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallistSoho] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForKeyword] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForRegisterDate] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForLogin] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForAge] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForGender] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForVIPGrade] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForLunchPath] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForAlarm] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForInstallDate] value:nil];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForUpdateDate] value:nil];
    [self.tracker set:nil value:nil];
    self.tracker = nil;
}

- (NSString *)getCurrentDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}


#pragma mark - event tracking

- (void)installEvent
{
    [self initializeTracker];

    [self.tracker set:kGAIScreenName value:@"splash"];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForInstallDate] value:[self getCurrentDate]];
    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"install" action:@"install" label:@"처음 설치" value:nil] build];
    [self sendTracker:event];
}

- (void)updateEvent
{
    [self initializeTracker];

    [self.tracker set:kGAIScreenName value:@"splash"];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForUpdateDate] value:[self getCurrentDate]];
    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"install" action:@"update" label:@"앱 업데이트" value:nil] build];
    [self sendTracker:event];
}

- (void)locationEvent
{
    [self initializeTracker];

}

- (void)loginEvent:(BOOL)isAutoLogin
{
    [self initializeTracker];

    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSDate *birth = (NSDate *)[pref objectForKey:@"auth.birth_date"];
    NSString *age = nil;
    if(birth)
    {
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSInteger birthYear = [[calendar components:NSYearCalendarUnit fromDate:birth] year];
        NSInteger thisYear = [[calendar components:NSYearCalendarUnit fromDate:[NSDate date]] year];
        age = [NSString stringWithFormat:@"%d", thisYear - birthYear + 1];
    }
    NSString *gender = [pref objectForKey:@"auth.gender"];
    NSString *vipgrade = [pref objectForKey:@"auth.vip_member_grade"];
    if(age)     [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForAge] value:age];
    if(gender)  [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForGender] value:gender];
    if(vipgrade)[self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForVIPGrade] value:vipgrade];

    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForLogin] value:@"Y"];
    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"login" label:nil value:isAutoLogin?@1:@0] build];
    [self sendTracker:event];
}

- (void)logoutEvent
{
    [self initializeTracker];

    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForLogin] value:@"N"];
    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"logout" label:nil value:nil] build];
    [self sendTracker:event];
}

- (void)shareEvent:(enumShareType)type code:(enumShareCode)code serail:(int)serial;
{
    [self initializeTracker];

    if(!serial || serial < 0)
        return;

    NSString *label = [NSString stringWithFormat:@"%@%d", SHARE_TYPE[type], serial];
    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"share" label:label value:@(code)] build];
    [self sendTracker:event];
}

- (void)pokrEvent:(int)serial isPoke:(BOOL)isPoke
{
    [self initializeTracker];

    if(!serial || serial < 0)
        return;

    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"wish" label:[NSString stringWithFormat:@"d%d", serial] value:[NSNumber numberWithBool:isPoke]] build];
    [self sendTracker:event];
}

- (void)cartEvent:(int)serial
{
    [self initializeTracker];
    
    if(!serial || serial < 0)
        return;

    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"cart" label:[NSString stringWithFormat:@"d%d", serial] value:nil] build];
    [self sendTracker:event];
}

- (void)pushEvent:(enumPushActionType)actionType pushType:(NSString *)pushType serial:(int)serial
{
    [self initializeTracker];
    
    if(!pushType || [@"" isEqualToString:pushType])
        return;

    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"push" action:PUSH_TYPE[actionType] label:pushType value:@(serial)] build];
    [self sendTracker:event];
}

- (void)promotionEvent:(enumPromotionType)promotionType promotionKind:(enumPromotionKind)promotionKind serial:(int)serial
{
    [self initializeTracker];
    
    if(!serial || serial < 0)
        return;

    NSDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"promotion" action:PROMOTION_TYPE[promotionType] label:PROMOTION_KIND[promotionKind] value:@(serial)] build];
    [self sendTracker:event];
}

- (void)webviewEvent:(id)arg
{
    
}


#pragma mark - pageview tracking

- (void)homeDealListView:(NSString *)alias
{
    [self initializeTracker];

    if(!alias || [@"" isEqualToString:alias])
        return;

    [self.tracker set:kGAIScreenName value:[NSString stringWithFormat:@"deallist.%@", alias]];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallist] value:@"0"];
    [self sendTracker];
}

- (void)categoryDealListView:(NSString *)listname categorySrl:(int)categorySrl
{
    [self initializeTracker];

    if(!listname || [@"" isEqualToString:listname] || !categorySrl || categorySrl < 0)
        return;

    [self.tracker set:kGAIScreenName value:[NSString stringWithFormat:@"deallist.%@", listname]];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallist] value:[NSString stringWithFormat:@"%d", categorySrl]];
    [self sendTracker];
}

- (void)localDealListView:(int)areaId
{
    [self initializeTracker];

    NSString *demensionValue = areaId && areaId > 0 ? [NSString stringWithFormat:@"%d", areaId] : nil;
    [self.tracker set:kGAIScreenName value:[NSString stringWithFormat:@"deallist.%@", areaId && areaId > 0 ? @"local" : @"near" ]];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallist] value:demensionValue];
    [self sendTracker];
}

- (void)sohoShopListView:(NSString *)alias
{
    [self initializeTracker];

    [self.tracker set:kGAIScreenName value:[NSString stringWithFormat:@"deallist.%@", alias]];
    [self sendTracker];
}

- (void)sohoDealListView:(int)categorySrl partnerSrl:(int)partnerSrl
{
    [self initializeTracker];

    if(categorySrl < 0 || !partnerSrl || partnerSrl < 0)
        return;

    [self.tracker set:kGAIScreenName value:@"deallist.fashion_soho"];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallist] value:[NSString stringWithFormat:@"%d", categorySrl]];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallistSoho] value:[NSString stringWithFormat:@"%d", partnerSrl]];
    [self sendTracker];
}

- (void)dealDetailView:(int)dealSrl categorySrl:(int)categorySrl
{
    [self initializeTracker];

    if(!dealSrl || dealSrl < 0 || !categorySrl || categorySrl < 0)
        return;

    [self.tracker set:kGAIScreenName value:@"deal"];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDetail] value:[NSString stringWithFormat:@"%d", dealSrl]];
    [self.tracker set:[GAIFields customDimensionForIndex:EnumDemensionForDeallist] value:[NSString stringWithFormat:@"%d", categorySrl]];
    [self sendTracker];
}

- (void)webviewEcommerceView:(NSString *)tranId affiliation:(NSString *)affiliation
                     revenue:(NSNumber *)revenue tax:(NSNumber *)tax shipping:(NSNumber *)shipping
                    currency:(NSString *)currency
{
    [self initializeTracker];

    if(!tranId || [@"" isEqualToString:tranId])
        return;

    NSDictionary *transaction = [[GAIDictionaryBuilder createTransactionWithId:tranId affiliation:affiliation revenue:revenue tax:tax shipping:shipping currencyCode:currency] build];
    [self sendTracker:transaction];
}

- (void)webviewEcommerceViewById:(NSString *)tranId name:(NSString *)name
                             sku:(NSString *)sku category:(NSString *)category
                           price:(NSNumber *)price quantity:(NSNumber *)quantity
                        currency:(NSString *)currency
{
    [self initializeTracker];

    if(!tranId || [@"" isEqualToString:tranId])
        return;

    NSDictionary *transaction = [[GAIDictionaryBuilder createItemWithTransactionId:tranId name:name sku:sku category:category price:price quantity:quantity currencyCode:currency] build];
    [self sendTracker:transaction];
}


- (void)webviewPageView:(NSString *)screenName
{
    [self webviewPageView:screenName jsonText:nil];
}

- (void)webviewPageView:(NSString *)screenName jsonText:(NSString *)jsonText
{
    [self initializeTracker];

    if(!screenName || [@"" isEqualToString:screenName] )
        return;

    if(jsonText)
    {
        //json pasing
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonText dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if(!error)
        {
            //set demension
            for(NSString *key in [json allKeys])
                [self.tracker set:[GAIFields customDimensionForIndex:[key intValue]] value:json[key]];
        }
    }

    [self.tracker set:kGAIScreenName value:screenName];
    [self sendTracker];
}





@end
