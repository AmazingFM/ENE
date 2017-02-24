//
//  YMGlobal.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMGlobal.h"
#import "YMLocalResource.h"
#import "PPNetworkHelper.h"
#import "YMDataManager.h"

void initialize()
{
    UIDevice *device = [UIDevice currentDevice];
    g_nOSVersion = [device.systemVersion floatValue];
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    g_strVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    g_screenWidth = [UIScreen mainScreen].bounds.size.width;
    g_screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [YMLocalResource sharedResource];
    [PPNetworkHelper startMonitoringNetwork];
}

void showAlert(NSString* msg){
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [alert show];
}

void showAlertDelegate(NSString* msg,id<UIAlertViewDelegate> delegate){
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:delegate cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [alert show];
}

void showErrorAlert(NSString* title,NSString* msg){
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
    });
}

void showDefaultAlert(NSString* title,NSString* msg){
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
    [alert show];
}


UIBarButtonItem* createBarItemIcon(NSString* iconName ,id target, SEL selector){
    UIBarButtonItem* barItem=nil;
    if(g_nOSVersion>=7){
        barItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:iconName] style:UIBarButtonItemStyleDone target:target action:selector];
    }else {
        UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
        btn.frame=CGRectMake(0,0,32,32);
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        barItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    return barItem;
}

UIBarButtonItem* createBarItemTitle(NSString* title ,id target, SEL selector){
    UIBarButtonItem* barItem=nil;

    UIButton* btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame=CGRectMake(0,0,40,32);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    barItem=[[UIBarButtonItem alloc] initWithCustomView:btn];

    return barItem;
}

@implementation YMGlobal

@end
