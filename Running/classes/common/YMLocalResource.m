//
//  YMLocalResource.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMLocalResource.h"
#import "YMUtil.h"

@implementation YMLocalResource

+(instancetype)sharedResource{
    static YMLocalResource *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

-(id)loadConfigFile:(NSString*)fileName{
    NSString* documentFilePath=[self documentFilePathWithName:fileName];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:documentFilePath]){
        //载入Document中配置
        return [self loadFileWithPath:documentFilePath];
    }else{
        //从NSBundle中获取，并保存到Document目录中
        NSString* sourcePath = [[NSBundle mainBundle] bundlePath];
        NSString* filePath = [sourcePath stringByAppendingPathComponent:fileName];
        if([fileManager fileExistsAtPath:filePath]){
            NSData* fileData=[NSData dataWithContentsOfFile:filePath];
            [self saveFileToDocument:fileData withName:fileName];
            return [self loadFileWithPath:filePath];
        }
        return nil;
    }
}

-(id)loadBundleFile:(NSString*)fileName{
    NSString* sourcePath = [[NSBundle mainBundle] bundlePath];
    NSString* filePath = [sourcePath stringByAppendingPathComponent:fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        return [self loadFileWithPath:filePath];
    }
    return nil;
}

-(id)loadFileWithPath:(NSString*)filePath{
    if([filePath hasSuffix:@"json"]){
        NSError* error=nil;
        NSString* fileData=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if(fileData!=nil){
            return [YMUtil JSONFromString:fileData];//[fileData JSONValue];
        }
    }else if([filePath hasSuffix:@"plist"]){
        return [NSDictionary dictionaryWithContentsOfFile:filePath];
    }else {
        return [NSData dataWithContentsOfFile:filePath];
    }
    return nil;
}

-(NSString*)documentFilePathWithName:(NSString*)fileName{
    NSArray *paths         = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath =[paths objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:fileName];
}

-(BOOL)saveFileToDocument:(NSData*)data withName:(NSString*)fileName{
    NSArray *paths         = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *realPath     = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return [data writeToFile:realPath atomically:YES];
}

+(id)loadLocalPlist:(NSString *)fileName{
    NSString * configPath  = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    if(configPath!=nil){
        return [NSDictionary dictionaryWithContentsOfFile:configPath];
    }
    return nil;
}
@end
