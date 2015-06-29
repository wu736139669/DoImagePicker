//
//  DoImagePickerController.m
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import "DoImagePickerController.h"
#import "AssetHelper.h"
#import "DoAlbumCell.h"
#import "DoPhotoCell.h"
#import "DoImagePickerGroupViewController.h"
#import "DoPhotoBrowser.h"

@implementation DoImagePickerController
{
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _noSelect = nil;
        _isResolutionImg = NO;
        _nMaxCount = 8;
        _nColumnCount = 4;
        _nResultType = DO_PICKER_RESULT_UIIMAGE;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    
    if ([ASSETHELPER getPhotoCountOfCurrentGroup] > 0) {
        NSLog(@"%ld",[ASSETHELPER getPhotoCountOfCurrentGroup]);
            [_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[ASSETHELPER getPhotoCountOfCurrentGroup]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    [super viewWillAppear:animated];
    [_cvPhotoList reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSVersion>=7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
//    [self.navigationItem setTitle:@"图片"];
    [self initBottomMenu];
    [self initControls];
    _imgType = ASSET_PHOTO_SCREEN_SIZE;
    _selectQualty.hidden = YES;
    if (_isResolutionImg) {
        [_selectQualty setSelected:YES];
        _imgType = ASSET_PHOTO_FULL_RESOLUTION;
    }else{
        [_selectQualty setSelected:NO];
        _imgType = ASSET_PHOTO_SCREEN_SIZE;
    }
    
//    [_selectQualty setTitleColor:[UIColor colorWithHexString:@"#0099e6" alpha:1]forState:UIControlStateNormal];
    
    //取消按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancel:)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStyleBordered target:self action:@selector(onSelectAlbum:)];
    
    UINib *nib = [UINib nibWithNibName:@"DoPhotoCell" bundle:nil];
    [_cvPhotoList registerNib:nib forCellWithReuseIdentifier:@"DoPhotoCell"];
        
    [_btOK setImageWithColor:[UIColor buttonMainColor]];
    _btOK.enabled = NO;
    // new photo is located at the first of array
    ASSETHELPER.bReverse = YES;
	if (_nMaxCount >= 1)
	{
		// init gesture for multiple selection with panning
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanForSelection:)];
		[self.view addGestureRecognizer:pan];
	}

    // init gesture for preview
    
    // add observer for refresh asset data
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnterForeground:)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
}


- (void)viewDidAppear:(BOOL)animated
{
//    [_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[ASSETHELPER getPhotoCountOfCurrentGroup]-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    [super viewDidAppear:animated];
    if (_dSelected.count > 0) {
        _btOK.enabled = YES;
    }else{
        _btOK.enabled = NO;
    }

    [_btOK setTitle:[NSString stringWithFormat:@"完成(%d/%d)", (int)_dSelected.count, (int)_nMaxCount] forState:UIControlStateNormal];
    [_btOK setTitle:[NSString stringWithFormat:@"完成(%d/%d)", (int)_dSelected.count, (int)_nMaxCount] forState:UIControlStateDisabled];
    [_cvPhotoList reloadData];
    
}
-(void)dealloc{
    if (_nResultType == DO_PICKER_RESULT_UIIMAGE)
        [ASSETHELPER clearData];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    _noSelect = nil;
}
- (void)handleEnterForeground:(NSNotification*)notification
{
//    [self readAlbumList];
}

#pragma mark - for init
- (void)initControls
{
    // side buttons
    _btUp.backgroundColor = DO_SIDE_BUTTON_COLOR;
    _btDown.backgroundColor = DO_SIDE_BUTTON_COLOR;
    
    CALayer *layer1 = [_btDown layer];
	[layer1 setMasksToBounds:YES];
	[layer1 setCornerRadius:_btDown.frame.size.height / 2.0 - 1];
    
    CALayer *layer2 = [_btUp layer];
	[layer2 setMasksToBounds:YES];
	[layer2 setCornerRadius:_btUp.frame.size.height / 2.0 - 1];
    
    
    // dimmed view
    _vDimmed.alpha = 0.0;
    _vDimmed.frame = self.view.frame;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOnDimmedView:)];
//    [_vDimmed addGestureRecognizer:tap];
}

- (void)readAlbumList
{
    [ASSETHELPER getGroupList:^(NSArray *aGroups) {
        
        
//        self.navigationItem.leftBarButtonItem.title = [ASSETHELPER getGroupInfo:0][@"name"];
        [self.navigationItem setTitle:[ASSETHELPER getGroupInfo:0][@"name"]];
        [self showPhotosInGroup:0];
        
        if (aGroups.count == 1)
            _btSelectAlbum.enabled = NO;
        
        // calculate tableview's height
    }];
}

#pragma mark - for bottom menu
- (IBAction)imgModeSelectBtnClick:(id)sender {
    UIButton* button = (UIButton*)sender;
    if ( button.isSelected ) {
        button.selected = NO;
        _isResolutionImg = NO;
        _imgType = ASSET_PHOTO_SCREEN_SIZE;
    }else{
        button.selected = YES;
        _isResolutionImg = YES;
        _imgType = ASSET_PHOTO_FULL_RESOLUTION;
    }
}

- (void)initBottomMenu
{
//    _vBottomMenu.backgroundColor = DO_MENU_BACK_COLOR;
//    [_btSelectAlbum setTitleColor:DO_BOTTOM_TEXT_COLOR forState:UIControlStateNormal];
//    [_btSelectAlbum setTitleColor:DO_BOTTOM_TEXT_COLOR forState:UIControlStateDisabled];
    
    _ivLine1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]];
    _ivLine2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"line.png"]];
    
    if (_nMaxCount == DO_NO_LIMIT_SELECT)
    {
        _lbSelectCount.text = @"(0)";
        _lbSelectCount.textColor = DO_BOTTOM_TEXT_COLOR;
    }
    else if (_nMaxCount < 1)
    {
        // hide ok button
        _btOK.hidden = YES;
        _ivLine1.hidden = YES;
        
        CGRect rect = _btSelectAlbum.frame;
        rect.size.width = rect.size.width + 60;
        _btSelectAlbum.frame = rect;
        
        _lbSelectCount.hidden = YES;
    }
    else
    {
        _btOK.titleLabel.text = [NSString stringWithFormat:@"完成(%d/%d)",(int)_dSelected.count, (int)_nMaxCount];
        _lbSelectCount.textColor = DO_BOTTOM_TEXT_COLOR;
    }
}

- (IBAction)onSelectPhoto:(id)sender
{
    NSMutableArray *aResult = [[NSMutableArray alloc] initWithCapacity:_dSelected.count];

    if (_nResultType == DO_PICKER_RESULT_UIIMAGE)
    {
        for (int i = 0; i < _dSelected.count; i++)
            if ([ASSETHELPER getImageAtIndex:[_dSelected[i] integerValue] type:_imgType]) {
                [aResult addObject:[ASSETHELPER getImageAtIndex:[_dSelected[i] integerValue] type:_imgType]];
            }
        
    }
    else
    {
        for (int i = 0; i < _dSelected.count; i++)
            if ([ASSETHELPER getAssetAtIndex:[_dSelected[i] integerValue]] != nil) {
                [aResult addObject:[ASSETHELPER getAssetAtIndex:[_dSelected[i] integerValue]]];
            }
            
    }
   
    [_delegate didSelectPhotosFromDoImagePickerController:self result:aResult];
}

- (IBAction)onCancel:(id)sender
{
    
    
    [_delegate didCancelDoImagePickerController];
}

- (IBAction)onSelectAlbum:(id)sender
{
//    BOOL isAnimated = YES;
//    if ([sender isKindOfClass:[NSNumber class]]) {
//        isAnimated = NO;
//    }
//    DoImagePickerGroupViewController* doImagePickerGroupViewController = [[DoImagePickerGroupViewController alloc] initWithNibName:@"DoImagePickerGroupViewController" bundle:nil];
//    doImagePickerGroupViewController.delegate = self;
//    [self.navigationController pushViewController:doImagePickerGroupViewController animated:isAnimated];
    
}
#pragma mark - for DoImagePickerGroupViewControllerDelegate
-(void)didSelectAtIndex:(NSInteger)index
{
    _dSelected = nil;
    _dSelected = [[NSMutableArray alloc] initWithCapacity:_nMaxCount];
    _noSelect = nil;
    [self showPhotosInGroup:index];
    [self.navigationItem setTitle:[ASSETHELPER getGroupInfo:index][@"name"]];
}
#pragma mark - for side buttons
- (void)onTapOnDimmedView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        [self hideBottomMenu];
        
        if (_ivPreview != nil)
            [self hidePreview];
    }
}

- (IBAction)onUp:(id)sender
{
    [_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (IBAction)onDown:(id)sender
{
    [_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[ASSETHELPER getPhotoCountOfCurrentGroup] - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark - UITableViewDelegate for selecting album
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ASSETHELPER getGroupCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DoAlbumCell *cell = (DoAlbumCell*)[tableView dequeueReusableCellWithIdentifier:@"DoAlbumCell"];
    
    if (cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DoAlbumCell" owner:nil options:nil] lastObject];
    }

    NSDictionary *d = [ASSETHELPER getGroupInfo:indexPath.row];
    cell.lbAlbumName.text   = d[@"name"];
    cell.lbCount.text       = [NSString stringWithFormat:@"%@", d[@"count"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showPhotosInGroup:indexPath.row];
    [_btSelectAlbum setTitle:[ASSETHELPER getGroupInfo:indexPath.row][@"name"] forState:UIControlStateNormal];
    [self hideBottomMenu];
}

- (void)hideBottomMenu
{
    [UIView animateWithDuration:0.2 animations:^(void) {
        
        _vDimmed.alpha = 0.0;
        
        _ivShowMark.transform = CGAffineTransformMakeRotation(0);
        
        [UIView setAnimationDelay:0.1];

    }];
}

#pragma mark - UICollectionViewDelegate for photos
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return [ASSETHELPER getPhotoCountOfCurrentGroup];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DoPhotoCell *cell = (DoPhotoCell *)[_cvPhotoList dequeueReusableCellWithReuseIdentifier:@"DoPhotoCell" forIndexPath:indexPath];
    
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.ivPhoto.image = [ASSETHELPER getImageAtIndex:indexPath.row type:ASSET_PHOTO_THUMBNAIL];
    
    
	if (![self isInNumArray:_dSelected withIndex:indexPath.row])
		[cell setSelectMode:NO];
    else{

            [cell setSelectIndex:[_dSelected indexOfObject:[self isInNumArray:_dSelected withIndex:indexPath.row]]+1];
        
    }
    return cell;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
//    return UIEdgeInsetsZero;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DoPhotoBrowser *photoBrowser = nil;
    
    photoBrowser = [[DoPhotoBrowser alloc] initWithDelegate:self];
    
    // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    photoBrowser.wantsFullScreenLayout = YES;
    // Show action button to save, copy or email photos (defaults to NO)
    photoBrowser.displayActionButton = YES;
    photoBrowser.maxNum = _nMaxCount;
    photoBrowser.selectImgArray = _dSelected;
    photoBrowser.displayNavArrows = YES;
    // Example: allows second image to be presented first
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    [self.navigationController pushViewController:photoBrowser animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat currentScreenSizeRate = ([[UIScreen mainScreen] bounds].size.width)/320.0;
    if (_nColumnCount == 2)
        return CGSizeMake(158*currentScreenSizeRate, 158*currentScreenSizeRate);
    else if (_nColumnCount == 3)
        return CGSizeMake(104*currentScreenSizeRate, 104*currentScreenSizeRate);
    else if (_nColumnCount == 4)
        return CGSizeMake(70*currentScreenSizeRate, 70*currentScreenSizeRate);

    return CGSizeZero;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _cvPhotoList)
    {
        [UIView animateWithDuration:0.2 animations:^(void) {
            if (scrollView.contentOffset.y <= 50)
                _btUp.alpha = 0.0;
            else
//                _btUp.alpha = 1.0;
                _btUp.alpha = 0.0;
            
            if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height)
                _btDown.alpha = 0.0;
            else
//                _btDown.alpha = 1.0;
                _btUp.alpha = 0.0;
        }];
    }
}

// for multiple selection with panning
- (void)onPanForSelection:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (_ivPreview != nil)
        return;
    
    double fX = [gestureRecognizer locationInView:_cvPhotoList].x;
    double fY = [gestureRecognizer locationInView:_cvPhotoList].y;
	
    for (UICollectionViewCell *cell in _cvPhotoList.visibleCells)
	{
        float fSX = cell.frame.origin.x;
        float fEX = cell.frame.origin.x + cell.frame.size.width;
        float fSY = cell.frame.origin.y;
        float fEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (fX >= fSX && fX <= fEX && fY >= fSY && fY <= fEY)
        {
            NSIndexPath *indexPath = [_cvPhotoList indexPathForCell:cell];
            
            if (_lastAccessed != indexPath)
            {
				[self collectionView:_cvPhotoList didSelectItemAtIndexPath:indexPath];
            }
            
            _lastAccessed = indexPath;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        _lastAccessed = nil;
        _cvPhotoList.scrollEnabled = YES;
    }
}

// for preview
- (void)onLongTapForPreview:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (_ivPreview != nil)
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        double fX = [gestureRecognizer locationInView:_cvPhotoList].x;
        double fY = [gestureRecognizer locationInView:_cvPhotoList].y;
        
        NSIndexPath *indexPath = nil;
        for (UICollectionViewCell *cell in _cvPhotoList.visibleCells)
        {
            float fSX = cell.frame.origin.x;
            float fEX = cell.frame.origin.x + cell.frame.size.width;
            float fSY = cell.frame.origin.y;
            float fEY = cell.frame.origin.y + cell.frame.size.height;
            
            if (fX >= fSX && fX <= fEX && fY >= fSY && fY <= fEY)
            {
                indexPath = [_cvPhotoList indexPathForCell:cell];
                break;
            }
        }
        
        if (indexPath != nil)
            [self showPreview:indexPath.row];
    }
}
#pragma mark - for DoPhoteCellDelegate
-(void)selectAtIndex:(NSInteger)index
{
    NSIndexPath* indexPath =[NSIndexPath indexPathForRow:index inSection:0];

    if (_nMaxCount >= 1 || _nMaxCount == DO_NO_LIMIT_SELECT)
    {
        
		DoPhotoCell *cell = (DoPhotoCell *)[_cvPhotoList cellForItemAtIndexPath:indexPath];
        
		if ((![self isInNumArray:_dSelected withIndex:indexPath.row]) && (_nMaxCount > _dSelected.count))
		{

			// select
			[_dSelected addObject:[NSNumber numberWithInt:indexPath.row]];
            
            [cell setSelectIndex:_dSelected.count];
		}
		else if(([self isInNumArray:_dSelected withIndex:indexPath.row]))
		{
			// unselect
			[_dSelected removeObject:[self isInNumArray:_dSelected withIndex:indexPath.row]];
            //			[cell setSelectMode:NO];
            [_cvPhotoList reloadData];
            
		}else if (_nMaxCount <= _dSelected.count){
//            [RTUtil showStatusBarWarning:[NSString stringWithFormat:@"最多只能选择%d张",_nMaxCount]];
        }
        
        if (_nMaxCount == DO_NO_LIMIT_SELECT)
            _btOK.titleLabel.text = [NSString stringWithFormat:@"完成(%d)", (int)_dSelected.count];
        
        else{
            [_btOK setTitle:[NSString stringWithFormat:@"完成(%d/%d)", (int)_dSelected.count, (int)_nMaxCount] forState:UIControlStateNormal];
            [_btOK setTitle:[NSString stringWithFormat:@"完成(%d/%d)", (int)_dSelected.count, (int)_nMaxCount] forState:UIControlStateDisabled];
            if (_dSelected.count <= 0 ) {
                [_btOK setEnabled:NO];
            }else{
                [_btOK setEnabled:YES];
            }
        }
        
        
    }
    else
    {
        if (_nResultType == DO_PICKER_RESULT_UIIMAGE)
            [_delegate didSelectPhotosFromDoImagePickerController:self result:@[[ASSETHELPER getImageAtIndex:indexPath.row type:ASSET_PHOTO_SCREEN_SIZE]]];
        else
            [_delegate didSelectPhotosFromDoImagePickerController:self result:@[[ASSETHELPER getAssetAtIndex:indexPath.row]]];
    }

}
#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [ASSETHELPER getPhotoCountOfCurrentGroup];
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [MWPhoto photoWithImage:[ASSETHELPER getImageAtIndex:index type:ASSET_PHOTO_SCREEN_SIZE]];
}
-(void)selectImageIndexArray:(NSArray*)imgArray
{
    [self onSelectPhoto:nil];
}
#pragma mark - for photos
- (void)showPhotosInGroup:(NSInteger)nIndex
{
    

    if (_nMaxCount == DO_NO_LIMIT_SELECT)
    {
        _dSelected = [[NSMutableArray alloc] init];
        _lbSelectCount.text = @"(0)";
        
    }
    else if (_nMaxCount >= 1)
    {
        _dSelected = [[NSMutableArray alloc] initWithCapacity:_nMaxCount];
        if (_noSelect.count != 0) {
            //        _dSelected = _noSelect;
            _dSelected = [[NSMutableArray alloc] initWithArray:_noSelect];
        }
        _btOK.titleLabel.text = [NSString stringWithFormat:@"完成(%d/%d)", (int)_dSelected.count, (int)_nMaxCount];
    }

    [ASSETHELPER setBReverse:NO];
    [ASSETHELPER getPhotoListOfGroupByIndex:nIndex result:^(NSArray *aPhotos) {
        [_cvPhotoList reloadData];
        _cvPhotoList.alpha = 0.3;
        [UIView animateWithDuration:0.2 animations:^(void) {
            [UIView setAnimationDelay:0.1];
            _cvPhotoList.alpha = 1.0;
        }];
        
		if (aPhotos.count > 0)
		{
			[_cvPhotoList scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:aPhotos.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }

        _btUp.alpha = 0.0;

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (_cvPhotoList.contentSize.height < _cvPhotoList.frame.size.height)
                _btDown.alpha = 0.0;
            else
                _btDown.alpha = 0.0;
        });
    }];
}

- (void)showPreview:(NSInteger)nIndex
{
    [self.view bringSubviewToFront:_vDimmed];
    
    _ivPreview = [[UIImageView alloc] initWithFrame:_vDimmed.frame];
    _ivPreview.contentMode = UIViewContentModeScaleAspectFit;
    _ivPreview.autoresizingMask = _vDimmed.autoresizingMask;
    [_vDimmed addSubview:_ivPreview];
    
    _ivPreview.image = [ASSETHELPER getImageAtIndex:nIndex type:ASSET_PHOTO_SCREEN_SIZE];
    
    // add gesture for close preview
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanToClosePreview:)];
    [_vDimmed addGestureRecognizer:pan];
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        _vDimmed.alpha = 1.0;
    }];
}

- (void)hidePreview
{
    [self.view bringSubviewToFront:_vBottomMenu];
    
    [_ivPreview removeFromSuperview];
    _ivPreview = nil;

    _vDimmed.alpha = 0.0;
    [_vDimmed removeGestureRecognizer:[_vDimmed.gestureRecognizers lastObject]];
}

- (void)onPanToClosePreview:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.view];

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.2 animations:^(void) {
            
            if (_vDimmed.alpha < 0.7)   // close preview
            {
                CGPoint pt = _ivPreview.center;
                if (_ivPreview.center.y > _vDimmed.center.y)
                    pt.y = self.view.frame.size.height * 1.5;
                else if (_ivPreview.center.y < _vDimmed.center.y)
                    pt.y = -self.view.frame.size.height * 1.5;

                _ivPreview.center = pt;

                [self hidePreview];
            }
            else
            {
                _vDimmed.alpha = 1.0;
                _ivPreview.center = _vDimmed.center;
            }
            
        }];
    }
    else
    {
		_ivPreview.center = CGPointMake(_ivPreview.center.x, _ivPreview.center.y + translation.y);
		[gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        
        _vDimmed.alpha = 1 - ABS(_ivPreview.center.y - _vDimmed.center.y) / (self.view.frame.size.height / 2.0);
    }
}

#pragma mark - Others
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
-(id)isInNumArray:(NSMutableArray*)numArray withIndex:(NSInteger)index{
    
    for (NSNumber* num in numArray) {
        if (num.integerValue == index) {
            return num;
        }
    }
    return nil;
}
@end
