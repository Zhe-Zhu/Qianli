//
//  InviteFriendsViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "Global.h"

@interface InviteFriendsViewController (){
    NSMutableArray * _contacts;
    NSMutableArray *_filteredListContent;
    BOOL searchDisplayIsOn;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteBarButton;

@property (strong, nonatomic) UIBarButtonItem *sendIvitation;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;
- (IBAction)inviteFriends:(id)sender;

@end

@implementation InviteFriendsViewController

@synthesize contacts = _contacts;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *sendInvitation = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(inviteFriends:)];
    sendInvitation.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:sendInvitation];
    _sendIvitation = sendInvitation;
    [self.navigationItem setTitle:NSLocalizedString(@"inviteFriend", nil)];
   // [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

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
    
    if ((!_contacts) | ([_contacts count] == 0)) {
        [self getAddressBookPermission];
    }
    //[self performSelectorInBackground:@selector(getAddressBookPermission) withObject:nil];
    
    _tableView.sectionIndexColor = [UIColor colorWithRed:94/255.0 green:201/255.0 blue:217/255.0 alpha:1.0f];
    if (IS_OS_7_OR_LATER) {
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                  [UIColor blackColor],
                                                                                                  UITextAttributeTextColor,
                                                                                                  nil] 
                                                                                        forState:UIControlStateNormal];
    
    if (!IS_OS_7_OR_LATER) {
        UIImage *backButton = [[UIImage imageNamed:@"barButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButton = [[UIImage imageNamed:@"barButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButton
         forState:UIControlStateNormal
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonPressed = [[UIImage imageNamed:@"barButtonBackPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonPressed = [[UIImage imageNamed:@"barButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonPressed
         forState:UIControlStateHighlighted
         barMetrics:UIBarMetricsDefault];
        
        UIImage *backButtonDisabled = [[UIImage imageNamed:@"barButtonBackDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 5)];
        UIImage *barButtonDisabled = [[UIImage imageNamed:@"barButtonDisabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackButtonBackgroundImage:backButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
         setBackgroundImage:barButtonDisabled
         forState:UIControlStateDisabled
         barMetrics:UIBarMetricsDefault];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _contacts = nil;
}

- (void)clearAddressItems
{
    [_contacts removeAllObjects];
    [_filteredListContent removeAllObjects];
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
            [weakSelf loadAddressBook: addressBookRef];
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
    }
    
    // Create addressbook data model
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    
    for (NSInteger i = 0; i < nPeople; i++)
    {
        QianLiAddressBookItem *addressBook = [[QianLiAddressBookItem alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        NSString *nameString = (__bridge NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastNameString = (__bridge NSString *) ABRecordCopyValue(person, kABPersonLastNameProperty);
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
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if (lastNameString != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        
        if (nameString != nil) {
            addressBook.name = nameString;
        }
        else{
            continue;
        }
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
                NSString *value = (__bridge NSString*)ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        //addressBook.tel = (__bridge NSString*)value;
                        [addressBook.tel addObject:value];
                        break;
                    }
                    case 1: {// Email
                        addressBook.email = value;
                        break;
                    }
                }
            }
            CFRelease(valuesRef);
        }
        
        [addressBookTemp addObject:addressBook];
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
    if (contact.rowSelected) {
        [contactCell.checkBox setHidden:NO];
        contactCell.checkBox.frame = CGRectMake(275.5-25/2.0, 22.4-25/2.0, 25, 25);
    } else {
    [contactCell.checkBox setHidden:YES];
    }
    
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
        
        ContactTableViewCell *cell = (ContactTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = (UIButton *)cell.accessoryView;
        [button setSelected:checked];
        if (checked) {
            [cell.checkBox setHidden:NO];
            CGFloat width = 34.0f;
            CGFloat normalWidth = 25.0f;
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
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
{
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
{
	[self.searchDisplayController setActive:NO animated:YES];
    [self.searchBar resignFirstResponder];
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
	[self.searchDisplayController setActive:NO animated:YES];
    [self.searchBar resignFirstResponder];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ContentFiltering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if (!_filteredListContent) {
        _filteredListContent = [[NSMutableArray alloc] initWithCapacity:1];
    }
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

- (IBAction)inviteFriends:(id)sender
{
    NSMutableArray *recipients = [NSMutableArray array];
    for (NSArray *section in _contacts) {
        for (QianLiAddressBookItem *addressBook in section)
        {
            if (addressBook.rowSelected)
            {
                for (int i = 0; i < [addressBook.tel count]; ++i) {
                    [recipients addObject:[addressBook.tel objectAtIndex:i]];
                }
            }
        }
    }
    
    if ([MFMessageComposeViewController canSendText]) {
        CGFloat activitySize = 40;
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect frame = self.navigationController.navigationBar.frame;
        activityIndicator.frame = CGRectMake(275, (frame.size.height - activitySize) / 2.0, activitySize, activitySize);
        [self.navigationController.navigationBar addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [self.navigationItem setRightBarButtonItem:nil];
        
        //TODO: change the text
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        messageVC.recipients = recipients;
        if (IS_OS_7_OR_LATER) {
            if ([MFMessageComposeViewController canSendSubject]) {
                messageVC.subject = NSLocalizedString(@"emailSubject", nil);
            }
        }
        messageVC.body = NSLocalizedString(@"emailBody", nil);
        messageVC.messageComposeDelegate = self;
        [self presentViewController:messageVC animated:YES completion:^{
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            [self.navigationItem setRightBarButtonItem:_sendIvitation];
        }];
    }
}

#pragma mark  ---MFMessageComposeViewControllerDelegate---
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if(result == MessageComposeResultCancelled) {
        //Message cancelled
    } else if(result == MessageComposeResultSent) {
        //Message sent
    }
    else if (result == MessageComposeResultFailed){
        //
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
