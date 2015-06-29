//
//  DoImagePickerGroupViewController.h
//  XiaoYu
//
//  Created by xmfish on 14-7-30.
//  Copyright (c) 2014年 Benson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoImagePickerController.h"
@protocol DoImagePickerGroupViewControllerDelegate <NSObject>

-(void)didSelectAtIndex:(NSInteger)index;

@end
@interface DoImagePickerGroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    __weak id<DoImagePickerGroupViewControllerDelegate> _delegate;
    DoImagePickerController* _doImagePickerController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSMutableArray* groupArray;
@property (weak, nonatomic)id<DoImagePickerGroupViewControllerDelegate> delegate;
@property (strong, nonatomic)DoImagePickerController* doImagePickerController;
@end
