//
//  AssetHelper.m
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import "AssetHelper.h"

@implementation AssetHelper


+ (AssetHelper *)sharedAssetHelper
{
    static AssetHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AssetHelper alloc] init];
        [_sharedInstance initAsset];
    });
    
    return _sharedInstance;
}

- (void)initAsset
{
    if (self.assetsLibrary == nil)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        NSString *strVersion = [[UIDevice alloc] systemVersion];
        if ([strVersion compare:@"5"] >= 0)
            [_assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            }];
    }
}

- (void)getGroupList:(void (^)(NSArray *))result
{
    [self initAsset];
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
    {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];

        if (group == nil)
        {
            if (_bReverse)
                _assetGroups = [[NSMutableArray alloc] initWithArray:[[_assetGroups reverseObjectEnumerator] allObjects]];
            
            
            for (ALAssetsGroup* group in _assetGroups) {
                if ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == 16) {
                    [_assetGroups exchangeObjectAtIndex:0 withObjectAtIndex:[_assetGroups indexOfObject:group]];
                    break;
                }
            }
            for (ALAssetsGroup* group in _assetGroups) {
                if ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == 32) {
                    [_assetGroups exchangeObjectAtIndex:1 withObjectAtIndex:[_assetGroups indexOfObject:group]];
                    break;
                }
            }
            // end of enumeration
            result(_assetGroups);
            return;
        }
//        //查看相册的名字
//        NSLog(@"ALAssetsGroupPropertyName:%@",[group valueForProperty:ALAssetsGroupPropertyName]);
//        //查看相册的类型
//        NSLog(@"ALAssetsGroupPropertyType:%@",[group valueForProperty:ALAssetsGroupPropertyType]);
//        //查看相册的存储id
//        NSLog(@"ALAssetsGroupPropertyPersistentID:%@",[group valueForProperty:ALAssetsGroupPropertyPersistentID]);
        [_assetGroups addObject:group];
    };
    
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error)
    {
        DLog(@"Error : %@", [error description]);
    };
    
    _assetGroups = [[NSMutableArray alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                  usingBlock:assetGroupEnumerator
                                failureBlock:assetGroupEnumberatorFailure];
}

- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result
{
    [self initAsset];
    
    _assetPhotos = [[NSMutableArray alloc] init];
    [alGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    [alGroup enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
        
        if(alPhoto == nil)
        {
            if (_bReverse)
                _assetPhotos = [[NSMutableArray alloc] initWithArray:[[_assetPhotos reverseObjectEnumerator] allObjects]];
            
            result(_assetPhotos);
            return;
        }
        
        [_assetPhotos addObject:alPhoto];
    }];
}

- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result
{
    [self getPhotoListOfGroup:_assetGroups[nGroupIndex] result:^(NSArray *aResult) {

        result(_assetPhotos);
        
    }];
}

- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *))error
{
    [self initAsset];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos)
            {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];

                [group enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
                    
                    if(alPhoto == nil)
                    {
                        if (_bReverse)
                            _assetPhotos = [[NSMutableArray alloc] initWithArray:[[_assetPhotos reverseObjectEnumerator] allObjects]];
                        
                        result(_assetPhotos);
                        return;
                    }
                    
                    [_assetPhotos addObject:alPhoto];
                }];
            }
        };
        
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *err)
        {
            DLog(@"Error : %@", [err description]);
            error(err);
        };
        
        _assetPhotos = [[NSMutableArray alloc] init];
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:assetGroupEnumerator
                                    failureBlock:assetGroupEnumberatorFailure];
    });
}

- (NSInteger)getGroupCount
{
    return _assetGroups.count;
}

- (NSInteger)getPhotoCountOfCurrentGroup
{
    return _assetPhotos.count;
}

- (NSDictionary *)getGroupInfo:(NSInteger)nIndex
{
    if ([_assetGroups[nIndex] valueForProperty:ALAssetsGroupPropertyName] && @([_assetGroups[nIndex] numberOfAssets]) && [UIImage imageWithCGImage:[_assetGroups[nIndex] posterImage]]) {
        return @{@"name" : [_assetGroups[nIndex] valueForProperty:ALAssetsGroupPropertyName],
                 @"count" : @([_assetGroups[nIndex] numberOfAssets]),
                 @"thumbnail" : [UIImage imageWithCGImage:[_assetGroups[nIndex] posterImage]]};
    }else{
        return nil;
    }

}

- (void)clearData
{
	_assetGroups = nil;
	_assetPhotos = nil;
}

#pragma mark - utils
- (UIImage *)getCroppedImage:(NSURL *)urlImage
{
    __block UIImage *iImage = nil;
    __block BOOL bBusy = YES;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        NSString *strXMP = rep.metadata[@"AdjustmentXMP"];
        if (strXMP == nil || [strXMP isKindOfClass:[NSNull class]])
        {
            CGImageRef iref = [rep fullResolutionImage];
            if (iref)
                iImage = [UIImage imageWithCGImage:iref scale:1.0 orientation:(UIImageOrientation)rep.orientation];
            else
                iImage = nil;
        }
        else
        {
            // to get edited photo by photo app
            NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
            
            CIImage *image = [CIImage imageWithCGImage:rep.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP
                                                         inputImageExtent:image.extent
                                                                    error:&error];
            if (error) {
                DLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            
            iImage = [UIImage imageWithCIImage:image scale:1.0 orientation:(UIImageOrientation)rep.orientation];
        }
        
		bBusy = NO;
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        DLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    [_assetsLibrary assetForURL:urlImage
                    resultBlock:resultblock
                   failureBlock:failureblock];
    
	while (bBusy)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    return iImage;
}

- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType
{
    CGImageRef iRef = nil;
//    NSLog(@"%@",[asset valueForProperty:ALAssetPropertyAssetURL]);
    if (nType == ASSET_PHOTO_THUMBNAIL)
        iRef = [asset thumbnail];
    else if (nType == ASSET_PHOTO_SCREEN_SIZE)
        iRef = [asset.defaultRepresentation fullScreenImage];
    else if (nType == ASSET_PHOTO_FULL_RESOLUTION)
    {
//        NSString *strXMP = asset.defaultRepresentation.metadata[@"AdjustmentXMP"];
//        NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
//        
//        CIImage *image = [CIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
//        
//        NSError *error = nil;
//        NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP
//                                                     inputImageExtent:image.extent
//                                                                error:&error];
//        if (error) {
//            NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
//        }
//        
//        for (CIFilter *filter in filterArray) {
//            [filter setValue:image forKey:kCIInputImageKey];
//            image = [filter outputImage];
//        }
//        
//        UIImage *iImage = [UIImage imageWithCIImage:image scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
//        return iImage;
        iRef = [asset.defaultRepresentation fullResolutionImage];
    }
    
    return [UIImage imageWithCGImage:iRef];
}

- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType
{
    if (_assetPhotos.count > nIndex) {
        return [self getImageFromAsset:(ALAsset *)_assetPhotos[nIndex] type:nType];
    }
    return nil;
}

- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex
{
    return _assetPhotos[nIndex];
}

@end
