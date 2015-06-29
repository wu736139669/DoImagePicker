//
//  DoSureBtn.m
//  XiaoYu
//
//  Created by xmfish on 14-9-26.
//  Copyright (c) 2014年 厦门小鱼网. All rights reserved.
//

#import "DoSureBtn.h"

@implementation DoSureBtn

+(DoSureBtn*)instance
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"DoSureBtn" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [_sureBtn setImageWithColor:[UIColor buttonMainColor]];
    _sureBtn.enabled = NO;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


-(void)setNum:(NSUInteger)num
{
    if (num==0) {
        _sureBtn.enabled = NO;
    }else{
        _sureBtn.enabled = YES;
    }
    [_sureBtn setTitle:[NSString stringWithFormat:@"完成(%d/%d)", num,_maxCount] forState:UIControlStateNormal];
    [_sureBtn setTitle:[NSString stringWithFormat:@"完成(%d/%d)", num, _maxCount] forState:UIControlStateDisabled];
}
- (IBAction)sureBtnClick:(id)sender {
}
@end
