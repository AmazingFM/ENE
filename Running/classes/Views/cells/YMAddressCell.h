//
//  YMAddressCell.h
//  Running
//
//  Created by 张永明 on 16/10/2.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YMCellItems.h"

typedef NS_ENUM(NSUInteger,YMAddressAction)
{
    YMAddressActionDefault,
    YMAddressActionEdit,
    YMAddressActionDelete,
};

@protocol YMAddressCellDelegate <NSObject>

- (void)modifyAddress:(YMAddressItem *)addressItem withType:(YMAddressAction)type;

@end

@interface YMAddressCell : UITableViewCell

@property (nonatomic, retain) YMAddressItem *addressItem;
@property (nonatomic, weak) id<YMAddressCellDelegate> delegate;

@end
