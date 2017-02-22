//
//  YMUtil.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YMUtil : NSObject

+ (NSString *)getUUID;

#pragma mark Font Size计算
+ (CGSize)sizeOfString:(NSString *)text withWidth:(float)width font:(UIFont *)font;

+ (CGSize)sizeWithFont:(NSString *)text withFont:(UIFont *)font;

#pragma mark JSON处理

+(NSDictionary*)loadLocalDataWithName:(NSString*)fileName;

+(NSData*)dataFromJSON:(NSObject*)jsonObj;
+(NSData*)dataFromGBKJSON:(NSObject*)jsonObj;
+(NSString*)stringFromJSON:(NSObject*)jsonObj;
+(NSObject*)JSONFromString:(NSString*)jsonStr;

+(NSString*)documentFilePathWithName:(NSString*)fileName;
+(BOOL)saveFileToDocument:(NSData*)data withName:(NSString*)fileName;

#pragma mark 存储
+(NSObject*)loadKey:(NSString*)key;
+(BOOL)saveKey:(NSString*)key value:(NSObject*)value;

#pragma mark NSDate相关字符串处理
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)dateStr withFormat:(NSString *)format;
+ (NSString *)dateStringTransform:(NSString *)sourceStr fromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat;

#pragma mark UIImage处理
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIColor *)colorWithHex:(int)hexValue;
+ (NSString *)md5HexDigest:(NSString *)input;

+(BOOL)needUpgradeVersion:(NSString*)version newVersion:(NSString*)newVersion;

+(NSString*)decimalNumberMutiplyWithString:(NSString*)multiplierValue :(NSString *)multiplicandValue;
+(NSDictionary*)parseURLParams:(NSString*)str;

#pragma mark 价格计算
+ (NSString *)decimalMutiply:(NSString *)multiplierValue with:(NSString*)multiplicandValue;
+ (NSString *)decimalAdd:(NSArray *)elementArr;

#pragma mark 图像处理
+ (UIImage *)image:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage *)cutImage:(UIImage*)image withSize:(CGSize)toSize;
+ (NSData *)compressImage:(UIImage *)image;
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
