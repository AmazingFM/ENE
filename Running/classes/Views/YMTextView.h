//
//  YMTextView.h
//  Running
//
//  Created by 张永明 on 2017/2/25.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMTextView : UITextView

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, retain) NSAttributedString *attributedPlaceholder;

- (CGRect)placeholderRectForBounds:(CGRect)bounds;

@end
