//
//  ImagePickerViewController.m
//  QianLi
//
//  Created by lutan on 8/26/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "ImagePickerViewController.h"

@interface ImagePickerViewController (){
    NSMutableArray *_assets;
    NSMutableArray *_selectedAssets;
}

@end

@implementation ImagePickerViewController

@synthesize assetsGroup = _assetsGroup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelectImages)];
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelectImages)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneSelectImages)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.pickerCollectionView registerClass:[AssetCell class] forCellWithReuseIdentifier:@"AssetCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Add additional code
    self.title = [_assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!_assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [_assets removeAllObjects];
    }
    
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] init];
    } else {
        [_selectedAssets removeAllObjects];
    }

    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [_assets addObject:result];
        }
        else
        {
            [self.pickerCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [_assetsGroup setAssetsFilter:onlyPhotosFilter];
    [_assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self scrollToBottom];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _assets = nil;
    _selectedAssets = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)upDateSelectedArray:(ALAsset *)set ToAdd:(BOOL)toAdd
{
    if (toAdd) {
        [_selectedAssets addObject:set];
    }
    else{
        [_selectedAssets removeObject:set];
    }
    //NSLog(@"%d",[_selectedAssets count]);
}

- (void)doneSelectImages
{
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:1];
    for (int i = 0; i < [_selectedAssets count]; ++i) {
        ALAsset *asset = [_selectedAssets objectAtIndex:i];
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage] scale:[assetRepresentation scale] orientation:(UIImageOrientation)0];

        UIImage *image;
        if (fullScreenImage.size.height > 480) {
            image = [fullScreenImage imageByResizing: CGSizeMake(fullScreenImage.size.width * 480 / fullScreenImage.size.height, 480)];
        }
        else if(fullScreenImage.size.width > 640){
            image = [fullScreenImage imageByResizing: CGSizeMake(640, fullScreenImage.size.height * 640 / fullScreenImage.size.width)];
        }
        else{
            image = fullScreenImage;
        }
        [imageArray addObject:image];
    }
    [_delegate didFinishSelectingImage:imageArray];
    [self dismissViewControllerAnimated:YES completion: nil];
}

-(void)scrollToBottom
{ // 保证用户可以选择到最新的图片
    NSInteger section = [_pickerCollectionView numberOfSections] - 1;
    NSInteger item = [_pickerCollectionView numberOfItemsInSection:section] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    if (item < 0) {
        return;
    }
    [_pickerCollectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

# pragma mark - UICollectionView DataSource Delegate
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [_assets count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    AssetCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    if (!cell) {
        // 其实这里的frame写什么都对显示无影响
        cell = [[AssetCell alloc] initWithFrame:CGRectMake(0, 0, 73, 73)];
    }
    if (indexPath.row >= [_assets count]) {
        return nil;
    }
    ALAsset *asset = [_assets objectAtIndex:indexPath.row];
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    cell.imageView.image = thumbnail;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AssetCell *cell = (AssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (![cell viewWithTag:9999]) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkBox.png"]];
        // 加入动画效果
        image.frame = CGRectMake(cell.bounds.size.width-25/2.0, cell.bounds.size.height-25/2.0, 0, 0);
        image.tag = 9999;
        [cell addSubview:image];
        [self upDateSelectedArray:[_assets objectAtIndex:indexPath.row] ToAdd:YES];
        [UIView animateWithDuration:0.2f animations:^{
            image.frame = CGRectMake(cell.bounds.size.width-26, cell.bounds.size.height-26, 27, 27);
        }completion:^(BOOL finished){
            [UIView animateWithDuration:0.1f animations:^{
            image.frame = CGRectMake(cell.bounds.size.width-25, cell.bounds.size.height-25, 25, 25);
            }];
        }];
    }
    else{
        [UIView animateWithDuration:0.1f animations:^{
            [cell viewWithTag:9999].frame = CGRectMake(cell.bounds.size.width-25/2.0, cell.bounds.size.width-25/2.0, 0, 0);
        } completion:^(BOOL finished) {
        [[cell viewWithTag:9999] removeFromSuperview];
        }];
        [self upDateSelectedArray:[_assets objectAtIndex:indexPath.row] ToAdd:NO];
    }
    if ([_selectedAssets count] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(73, 73);
}

@end
