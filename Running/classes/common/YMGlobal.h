//
//  YMGlobal.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#import "YMMainViewController.h"

//#ifdef YM_DEBUG
//#define NSLog(fmt, ...)     NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#define NSLog(fmt, ...)     NSLog((@"" fmt), ##__VA_ARGS__);
//#else
//#define NSLog(...)
//#endif

extern float g_nOSVersion;
extern NSString *g_strVersion;
extern int g_BuildNumber;

extern float g_screenWidth;
extern float g_screenHeight;

extern AppDelegate *g_appDelegate;
extern UIWindow *g_mainWindow;
extern YMMainViewController *g_mainMenu;

extern void initialize();

void showAlert(NSString* msg);
void showAlertDelegate(NSString* msg,id<UIAlertViewDelegate> delegate);
void showErrorAlert(NSString* title,NSString* msg);
void showDefaultAlert(NSString* title,NSString* msg);
UIBarButtonItem* createBarItemIcon(NSString* iconName ,id target, SEL selector);
UIBarButtonItem* createBarItemTitle(NSString* title ,id target, SEL selector);
#define kYMTableViewDefaultRowHeight 44.f

#define YM_PAGE_SIZE 20
#define YM_APPID @"2"

#define kYM_APPID @"app_id"
#define kYM_REQSEQ @"req_seq"
#define kYM_TIMESTAMP @"time_stamp"
#define kYM_SIGN @"sign"
#define kYM_REMARKCODE @"remark_code"
#define kYM_RESPID @"resp_id"
#define kYM_RESPDESC @"resp_desc"
#define kYM_RESPDATA @"resp_data"

#define kYM_TOKEN @"token"
#define kYM_PAGENO @"current_page"
#define kYM_PAGESIZE @"page_size"

#define kYM_USERID @"user_id"

//登陆
#define kYM_USERNAME @"user_name"
#define kYM_PASSWORD @"user_pass"
#define kYM_USERICON @"user_icon"
#define kYM_ID @"id"
#define kYM_NICKNAME @"nick_name"
#define kYM_USERTYPE @"user_type"

//商品列表
#define kYM_SPECID @"spec_id"
#define kYM_KEYWORDS @"key_words"

//商品详情
#define kYM_GOODSID @"goods_id"
#define kYM_SUBGID @"sub_gid"

//商品列表详情信息
#define kYM_GOODSARRAY @"goods_array"

//订单list查询
#define kYM_BEGINTIME @"begin_time"
#define kYM_ENDTIME @"end_time"
#define kYM_ORDERSTATUS @"status"

@interface YMGlobal : NSObject

@end
