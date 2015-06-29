//
//  DoSelectBtn.h
//  XiaoYu
//
//  Created by xmfish on 14-9-26.
//  Copyright (c) 2014年 厦门小鱼网. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoSelectBtn : UIView
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
+(DoSelectBtn*)instance;
-(void)setNum:(NSUInteger)num;
- (void)setSelectMode:(BOOL)bSelect;
@end
