//
//  YMCommon.h
//  Running
//
//  Created by freshment on 16/9/3.
//  Copyright © 2016年 ming. All rights reserved.
//

#ifndef YMCommon_h
#define YMCommon_h

#define kYMNoticeLoginInIdentifier @"kYMNoticeLoginIdentifier"
#define kYMNoticeLoginOutIdentifier @"kYMNoticeLoginOutIdentifier"
#define kYMNoticeShoppingCartIdentifier @"kYMNoticeShoppingCartIdentifier"
#define kYMNoticePayResultIdentifier @"kYMNoticePayResultIdentifier"

#define kYMNoticeUserInfoUpdateIdentifier @"kYMNoticeUserInfoUpdateIdentifier"

#define kYMMainViewHeight      (g_screenHeight-kYMTabbarHeight)
#define kYMTabbarHeight        49
#define kYMNavigationBarHeight 44
#define kYMScrollBarMenuHeight 40

#define kYMBorderMargin 15
#define kYMPadding  5

#define kYMBigFont [UIFont systemFontOfSize:17]
#define kYMNormalFont [UIFont systemFontOfSize:15]
#define kYMdetailFont [UIFont systemFontOfSize:13]
#define kYMSmallFont [UIFont systemFontOfSize:13]
#define kYMVerySmallFont [UIFont systemFontOfSize:12]

#define kYMTableHeaderFont [UIFont systemFontOfSize:14]
#define kYMFieldFont [UIFont systemFontOfSize:15]

#define rgba(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define kYMServerBaseURL @"http://api.longlifelink.net/ene/AppServ/index.php"//@"http://139.196.237.165/ene/AppServ/index.php"

#import "MJExtension.h"
#import "UIImageView+WebCache.h"

#endif /* YMCommon_h */
