//
//  DoImagePickerGroupViewController.m
//  XiaoYu
//
//  Created by xmfish on 14-7-30.
//  Copyright (c) 2014年 Benson. All rights reserved.
//

#import "DoImagePickerGroupViewController.h"
#import "DoImagePickerGroupCell.h"
#import "AssetHelper.h"
@interface DoImagePickerGroupViewController ()

@end

@implementation DoImagePickerGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _groupArray = nil;
        [ASSETHELPER setBReverse:NO];
        [ASSETHELPER getGroupList:^(NSArray* groups){
            _groupArray = [[NSMutableArray alloc] initWithArray:groups];
            [self.tableview reloadData];
        }];
        self.doImagePickerController = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"图片"];
    //取消按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancel:)];

}
- (void)onCancel:(id)sender
{
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_groupArray) {
        return _groupArray.count;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"Cell";
    DoImagePickerGroupCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[DoImagePickerGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ALAssetsGroup *assetsGroup = [_groupArray objectAtIndex:indexPath.row];
    
    cell.imageView.image = [UIImage imageWithCGImage:assetsGroup.posterImage];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", [assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    cell.countLabel.text = [NSString stringWithFormat:@"(%ld)", assetsGroup.numberOfAssets];

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    [_doImagePickerController didSelectAtIndex:indexPath.row];
    [self.navigationController pushViewController:_doImagePickerController animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
