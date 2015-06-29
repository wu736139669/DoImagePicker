# DoImagePicker
图片选择器

使用方法：

            DoImagePickerGroupViewController *doImagePickerGroupViewController = [[DoImagePickerGroupViewController alloc] init];
            doImagePickerGroupViewController.doImagePickerController.delegate = self;
            doImagePickerGroupViewController.doImagePickerController.nMaxCount = 8-_imgArray.count;
            
            UINavigationController* imagePickercontroller = [[UINavigationController alloc] initWithRootViewController:doImagePickerGroupViewController];
            [self presentViewController:imagePickercontroller animated:YES completion:nil];
            
            
            
实现这两个代理即可。
- (void)didCancelDoImagePickerController;
- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected;
