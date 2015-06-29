//
//  DoPhotoCell.h
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import <UIKit/UIKit.h>

@protocol DoPhotoCellDelegate <NSObject>

-(void)selectAtIndex:(NSInteger)index;
@end
@interface DoPhotoCell : UICollectionViewCell
{
    __weak id<DoPhotoCellDelegate> _delegate;
}

@property (weak, nonatomic) IBOutlet UIImageView    *ivPhoto;
@property (weak, nonatomic) IBOutlet UIView         *vSelect;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) id<DoPhotoCellDelegate>  delegate;
@property (weak, nonatomic) IBOutlet UIButton *isSelect;
- (IBAction)selectBtnClick:(id)sender;
- (void)setSelectMode:(BOOL)bSelect;
- (void)setSelectIndex:(NSInteger)index;
@end
