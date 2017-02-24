//
//  YMDefaultViewController.m
//  Running
//
//  Created by freshment on 16/9/25.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMDefaultViewController.h"


#import "YMDataManager.h"
#import "Config.h"

@interface YMDefaultViewController ()

@end

@implementation YMDefaultViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self performSelectorInBackground:@selector(getCityList) withObject:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserInfo:) name:kYMNoticeLoginInIdentifier object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doNothing) name:kYMNoticeLoginOutIdentifier object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kYMNoticeLoginInIdentifier object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kYMNoticeLoginOutIdentifier object:nil];
}
#pragma mark 网络请求

- (void)getUserInfo:(NSNotification *)notice
{
    //登录后获取地址列表
    NSDictionary *userInfo = notice.userInfo;
    NSString *user_id = userInfo[@"user_id"];
    
//    [self getParameters];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    parameters[kYM_USERID] = user_id;
    parameters[@"status"] = @"0";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserAddrList"] parameters:parameters success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                
                NSArray<YMAddress *> *addressList;
                if (dataDict) {
//                    int nCount = [dataDict[@"total_count"] intValue];
                    addressList = [YMAddress objectArrayWithKeyValuesArray:dataDict[@"usraddr_list"]];
                } else {
                    //无收货地址
                }
                
                [[YMDataManager shared] initWithAddressList:addressList];
            } else {
                //错误
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

- (void)doNothing
{
    
}

- (void)getCityList
{
//    if (![self getParameters]) {
//        return;
//    }
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"level"]=@"1";
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=CityQuery"] parameters:parameters success:^(id responseObject) {
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                NSDictionary *dataDict = respDict[kYM_RESPDATA];
                
//                int nCount = [dataDict[@"total_count"] intValue];
                
                NSArray<YMCity *> *cityArr = [YMCity objectArrayWithKeyValuesArray:dataDict[@"city_list"]];
                
                for (YMCity *city in cityArr) {
                    NSLog(@"%@-%@,%@-%@,%@-%@,%@", city.province_code, city.province,city.city_code, city.city, city.town_code,city.town,city.level);
                }
                
                [[YMDataManager shared] initWithCitylist:cityArr];

            } else {
                //
            }
        }
    } failure:^(NSError *error) {
        //
    }];
}

@end
