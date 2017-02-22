//
//  YMNetwork.m
//  Running
//
//  Created by 张永明 on 16/9/8.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMNetwork.h"

@implementation YMNetwork

-(instancetype)initWithServer:(NSString*)serverIP withPort:(int)port{
    self=[super init];
    if(self){
        self.serverIP=serverIP;
        self.serverPort=port;
    }
    return self;
}
-(void)connect{
}
-(void)disconnect{
}

@end
