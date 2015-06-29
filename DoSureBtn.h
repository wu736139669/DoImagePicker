//
//  DoSureBtn.h
//  XiaoYu
//
//  Created by xmfish on 14-9-26.
//  Copyright (c) 2014年 厦门小鱼网. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoSureBtn : UIView
@property (nonatomic)NSUInteger maxCount;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
- (IBAction)sureBtnClick:(id)sender;
-(void)setNum:(NSUInteger)num;
+(DoSureBtn*)instance;
@end
