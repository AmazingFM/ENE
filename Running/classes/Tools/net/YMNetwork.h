//
//  YMNetwork.h
//  Running
//
//  Created by 张永明 on 16/9/8.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMNetwork : NSObject

@property (nonatomic, copy) NSString *  serverIP;
@property (nonatomic) int               serverPort;
@property (nonatomic) BOOL              connected;

- (instancetype) initWithServer:(NSString *)serverIP withPort:(int)port;
- (void)connect;
- (void)disconnect;
@end
