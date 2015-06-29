//
//  DoPhotoCell.m
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import "DoPhotoCell.h"

@implementation DoPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (IBAction)selectBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(selectAtIndex:)]) {
        [self.delegate selectAtIndex:self.tag];
    }
}

- (void)setSelectMode:(BOOL)bSelect
{
    if (bSelect)
//        _ivPhoto.alpha = 0.2;
        _isSelect.selected = YES;
    
    else{
        //        _ivPhoto.alpha = 1.0;
        _isSelect.selected = NO;
        _indexLabel.hidden = YES;
    }

    
}
-(void)setSelectIndex:(NSInteger)index
{
    _indexLabel.hidden = NO;
    _isSelect.selected = YES;
    _indexLabel.text = [NSString stringWithFormat:@"%ld",index];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
