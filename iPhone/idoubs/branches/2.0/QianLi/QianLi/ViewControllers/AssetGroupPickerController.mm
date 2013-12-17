//
//  AssetGroupPickerController.m
//  QianLi
//
//  Created by lutan on 8/26/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "AssetGroupPickerController.h"
#import "AssetGroupCell.h"
#import "SipStackUtils.h"

@interface AssetGroupPickerController (){
    NSMutableArray *_groups;
    BOOL isFirstLoad; //记录是否第一次载入, 用以直接显示相册中的照片而不是相册列表
}

@property (weak, nonatomic) IBOutlet UITableView *assetGroupTableview;
@property(strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@end

@implementation AssetGroupPickerController

@synthesize assetGroupTableview = _assetGroupTableview;
@synthesize assetsLibrary = _assetsLibrary;

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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    isFirstLoad = YES;
    
    // Load asset
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (!_groups) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [_groups removeAllObjects];
    }
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] != ALAssetsGroupPhotoStream) {
                // 不加入照片流的图片
                // TODO 考虑如何加入照片流的图片
                [_groups addObject:group];
            }
        } else {
            // 把groups的顺序反转, 更方便用户查看
            NSEnumerator *enumerator = [_groups reverseObjectEnumerator];
            _groups = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
            [self.assetGroupTableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"object %@ failed to load assets groups", self);
    };
    
    NSUInteger groupTypes = ALAssetsGroupAll;
    [_assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *selectdPath = [_assetGroupTableview indexPathForSelectedRow];
    [_assetGroupTableview deselectRowAtIndexPath:selectdPath animated:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([_groups count] >= 1 && isFirstLoad) {
        isFirstLoad = NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        ImagePickerViewController *imagePicker = [storyboard instantiateViewControllerWithIdentifier:@"ImagePickerVC"];
        imagePicker.delegate = _delegate;
        imagePicker.assetsGroup = [_groups objectAtIndex:0];
        [self.navigationController pushViewController:imagePicker animated:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel
{
    [PictureManager endImageSession:[[PictureManager sharedInstance] getImageSession] Success:^(BOOL success) {
        NSLog(@"image session ends now in %@ by pressing cancel button", self);
    }];
    NSString *remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
    [[SipStackUtils sharedInstance].messageService sendMessage:kCancelAddImage toRemoteParty:remotePartyNumber];
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groups count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AssetCell";
	AssetGroupCell *assetCell = (AssetGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (assetCell == nil) {
		assetCell = [[AssetGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ALAssetsGroup *groupForCell = [_groups objectAtIndex:indexPath.row];
    CGImageRef posterImageRef = [groupForCell posterImage];
    UIImage *posterImage = [UIImage imageWithCGImage:posterImageRef];
    NSString *name = [groupForCell valueForProperty:ALAssetsGroupPropertyName];
    NSString *number = [NSString stringWithFormat:@"%d", groupForCell.numberOfAssets];
    assetCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [assetCell setCellWithImage:posterImage Name:name Number:number];
    return assetCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ImagePickerViewController *imagePicker = [storyboard instantiateViewControllerWithIdentifier:@"ImagePickerVC"];
    imagePicker.delegate = _delegate;
    imagePicker.assetsGroup = [_groups objectAtIndex:indexPath.row];
    if (imagePicker.assetsGroup.numberOfAssets > 0) {
        [self.navigationController pushViewController:imagePicker animated:YES];
    }
}

@end
