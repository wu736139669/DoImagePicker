//
//  DoSelectBtn.m
//  XiaoYu
//
//  Created by xmfish on 14-9-26.
//  Copyright (c) 2014年 厦门小鱼网. All rights reserved.
//

#import "DoSelectBtn.h"

@implementation DoSelectBtn

+(DoSelectBtn*)instance
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"DoSelectBtn" owner:nil options:nil];
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

}
-(void)setSelectMode:(BOOL)bSelect
{
    if (bSelect)
        //        _ivPhoto.alpha = 0.2;
        _selectBtn.selected = YES;
    
    else{
        //        _ivPhoto.alpha = 1.0;
        _selectBtn.selected = NO;
        _countLabel.hidden = YES;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setNum:(NSUInteger)num
{
    _countLabel.text = [NSString stringWithFormat:@"%d",num];
    _countLabel.hidden = NO;
    _selectBtn.selected = YES;
}
@end
