//
//  InviteFriendsViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "InviteFriendsViewController.h"

@interface InviteFriendsViewController (){
    NSMutableArray * _contacts;
    NSMutableArray *_filteredListContent;
    BOOL searchDisplayIsOn;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

@end

@implementation InviteFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //[_searchBar removeFromSuperview];
    _tableView.tableHeaderView = _searchBar;
    
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
	self.searchDisplayController.searchBar.showsCancelButton = NO;
    searchDisplayIsOn = NO;
    
    [self getAddressBookPermission];
    //[self performSelectorInBackground:@selector(getAddressBookPermission) withObject:nil];
    
    _tableView.sectionIndexColor = [UIColor colorWithRed:94/255.0 green:201/255.0 blue:217/255.0 alpha:1.0f];
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getAddressBookPermission
{
    
    if (ABAddressBookRequestAccessWithCompletion) { // if in iOS 6
        
        // Request authorization to Address Book
        CFErrorRef error = NULL;
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        InviteFriendsViewController * __weak weakSelf = self;  // avoid capturing self in the block
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been granted, add the contact
                if (granted) {
                    [weakSelf loadAddressBook: addressBookRef];
                    if (addressBookRef) {
                        CFRelease(addressBookRef);
                    }
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add the contact
            [self loadAddressBook: addressBookRef];
            if (addressBookRef) {
                CFRelease(addressBookRef);
            }
        }
        else {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
            NSLog(@"access denied!");
        }
    }
    else{ // if not in iOS 6
        // just get the contacts directly
        NSLog(@"ios5");
        ABAddressBookRef addressBookRef = ABAddressBookCreate();
        [self loadAddressBook: addressBookRef];
        if(addressBookRef)
        {CFRelease(addressBookRef);
        }
    }
}

- (void)loadAddressBook: (ABAddressBookRef) addressBooks
{
    if (!_contacts) {
        _contacts = [[NSMutableArray alloc] init];
        _filteredListContent = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    // Create addressbook data model
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    
    for (NSInteger i = 0; i < nPeople; i++)
    {
        QianLiAddressBookItem *addressBook = [[QianLiAddressBookItem alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        CFStringRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFStringRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        
        
        //Save thumbnail image - performance decreasing
        UIImage *personImage = nil;
        if (person != nil && ABPersonHasImageData(person)) {
            if ( &ABPersonCopyImageDataWithFormat != nil ) {
                // iOS >= 4.1
                CFDataRef contactThumbnailData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
                personImage = [UIImage imageWithData:(__bridge NSData*)contactThumbnailData];
                CFRelease(contactThumbnailData);
                CFDataRef contactImageData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
                CFRelease(contactImageData);
                
            } else {
                // iOS < 4.1
                CFDataRef contactImageData = ABPersonCopyImageData(person);
                personImage = [UIImage imageWithData:(__bridge NSData*)contactImageData];
                CFRelease(contactImageData);
            }
        }
        [addressBook setThumbnail: personImage];
        
        
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if ((__bridge id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        
        addressBook.name = nameString;
        addressBook.rowSelected = NO;
        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        //addressBook.tel = (__bridge NSString*)value;
                        [addressBook.tel addObject:(__bridge NSString*)value];
                        break;
                    }
                    case 1: {// Email
                        addressBook.email = (__bridge NSString*)value;
                        break;
                    }
                }
                CFRelease(value);
            }
            CFRelease(valuesRef);
        }
        
        [addressBookTemp addObject:addressBook];
        
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    
    CFRelease(allPeople);
    
    // Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    for (QianLiAddressBookItem *addressBook in addressBookTemp) {
        NSInteger sect = [theCollation sectionForObject:addressBook
                                collationStringSelector:@selector(name)];
        addressBook.sectionNumber = sect;
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity: 1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (QianLiAddressBookItem *addressBook in addressBookTemp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:addressBook.sectionNumber] addObject:addressBook];
    }
    
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(name)];
        [_contacts addObject:sortedSection];
    }
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
	} else {
        return [_contacts count];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filteredListContent count];
    } else {
        return [[_contacts objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactTableViewCell";
    
	ContactTableViewCell *contactCell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (contactCell == nil) {
		contactCell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		contactCell.frame = CGRectMake(0.0, 0.0, 320.0, 44);
    }
    
    QianLiAddressBookItem *contact = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        contact = (QianLiAddressBookItem *)[_filteredListContent objectAtIndex:indexPath.row];
    }
	else{
        contact = (QianLiAddressBookItem *)[[_contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    if (!contact.thumbnail) {
        contact.thumbnail = [UIImage imageNamed:@"blank.png"];
    }
    [contactCell setContactProfile: contact NeedIcon:NO];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(30.0, 0.0, 29, 29)];
    //	[button setBackgroundImage:[UIImage imageNamed:@"uncheckBox.png"] forState:UIControlStateNormal];
    //    [button setBackgroundImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateSelected];
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    [button setSelected:contact.rowSelected];
    
	contactCell.accessoryView = button;
    [contactCell.uncheckBox setHidden:NO];
    
	return contactCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_contacts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// Add vertical index for fast location
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[_contacts objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 0;
    return [[_contacts objectAtIndex:section] count] ? tableView.sectionHeaderHeight : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
		[self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else {
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	QianLiAddressBookItem *addressBook = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView){
		addressBook = (QianLiAddressBookItem*)[_filteredListContent objectAtIndex:indexPath.row];
        BOOL checked = !addressBook.rowSelected;
        addressBook.rowSelected = checked;
        
        UITableViewCell *cell =[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
        UIButton *button = (UIButton *)cell.accessoryView;
        [button setSelected:checked];
    }
	else if (tableView == self.tableView ){
        addressBook = (QianLiAddressBookItem*)[[_contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        BOOL checked = !addressBook.rowSelected;
        addressBook.rowSelected = checked;
        
        //        UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
        ContactTableViewCell *cell = (ContactTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = (UIButton *)cell.accessoryView;
        
        //        CGRect frame = button.frame;
        //        UIImageView *checkBox = [[UIImageView alloc] initWithFrame:frame];
        //        checkBox.image = [UIImage imageNamed:@"checkBox.png"];
        //
        //        [checkBox setAlpha:0.0f];
        //        [cell addSubview:checkBox];
        [button setSelected:checked];
        if (checked) {
            [cell.checkBox setHidden:NO];
            CGFloat width = 34.0f;
            CGFloat normalWidth = 28.0f;
            [UIView animateWithDuration:0.2f animations:^{
                cell.checkBox.frame = CGRectMake(275.5-width/2.0, 22.4-width/2.0, width, width);
            } completion:^(BOOL finished){
                [UIView animateWithDuration:0.1f animations:^{
                    cell.checkBox.frame = CGRectMake(275.5-normalWidth/2.0, 22.4-normalWidth/2.0, normalWidth, normalWidth);}];
            }];
        }
        else {
            CGRect zeroFrame = cell.checkBox.frame;
            zeroFrame.origin.x = zeroFrame.origin.x + zeroFrame.size.width/2.0;
            zeroFrame.origin.y = zeroFrame.origin.y + zeroFrame.size.height/2.0;
            zeroFrame.size.width = 0;
            zeroFrame.size.height = 0;
            [UIView animateWithDuration:0.1f animations:^{
                cell.checkBox.frame = CGRectMake(275.5, 22.4, 0, 0);
            } completion:^(BOOL finished) {
                [cell.checkBox setHidden:YES];
            }];
        }
        
        
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}


- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	
    if (searchDisplayIsOn) {
        CGPoint touchPosition = [touch locationInView:self.searchDisplayController.searchResultsTableView];
        NSIndexPath *searchIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForRowAtPoint: touchPosition];
        [self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:searchIndexPath];
    }
    else{
        if (indexPath != nil)
        {
            [self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        }
    }
}


//#pragma mark -
//#pragma mark UISearchBarDelegate
//
- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ContentFiltering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredListContent removeAllObjects];
    for (NSArray *section in _contacts) {
        for (QianLiAddressBookItem *addressBook in section)
        {
            NSComparisonResult result = [addressBook.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
            {
                [_filteredListContent addObject:addressBook];
            }
        }
    }
}

#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    searchDisplayIsOn = NO;
    [self.tableView reloadData];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    searchDisplayIsOn = YES;
}


@end
