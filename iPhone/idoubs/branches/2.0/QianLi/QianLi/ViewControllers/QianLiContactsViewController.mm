//
//  QianLiContactsViewController.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//  CODEREVIEW DONE

#import "QianLiContactsViewController.h"
#import "SipCallManager.h"
#import "NotificationHeader.h"

@interface QianLiContactsViewController()
{
    NSMutableArray *_contacts; // 已有联系人中注册了千里的号码
    NSMutableArray *_allContacts; // 所有联系人的号码
    NSMutableArray *_updateArray; // 需要去update信息的号码
    BOOL didLoadFromStarting;
    BOOL backFromInvite;
    double startingTime;
}
@property (nonatomic, weak) IBOutlet UITableView *friendsTableView;

@property (nonatomic, strong) UIButton *buttonInviteFriends;
@property (nonatomic, strong) NSDictionary *countryCode;
@property (nonatomic, strong) NSString *countryName; // 读运营商所提供的国家名字
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) UIImageView *noContactImageView; // 用于贴当没有联系人时的指示图
@property (nonatomic, weak) UILabel *noContactTitle;
@property (nonatomic, weak) UILabel *noContactBody;
@property (nonatomic, weak) UILabel *noContactBody2;

@property (nonatomic) BOOL finished; // 是否成功从服务器拿取数据
@property (nonatomic, weak) InviteFriendsViewController *inviteController;
@property (nonatomic, weak) NSThread *secondThread;

- (IBAction)inviteFriends:(id)sender;

@end

@implementation QianLiContactsViewController

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
    backFromInvite = NO;
    [self setCountryCodes];
    CGFloat buttonHeight = 60;
    _buttonInviteFriends = [UIButton buttonWithType:UIButtonTypeSystem];
    _buttonInviteFriends.frame = CGRectMake(5, 39, 320, buttonHeight);
    _buttonInviteFriends.backgroundColor = [UIColor whiteColor];
    [_buttonInviteFriends addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *inviteFriend = [[UIImageView alloc] initWithFrame:CGRectMake(20, (buttonHeight-1)/2.0-14, 34, 28)];
    inviteFriend.image = [UIImage imageNamed:@"inviteFriend.png"];
    [_buttonInviteFriends addSubview:inviteFriend];
    UIImageView *disclosureIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(306, (buttonHeight-1)/2.0-6, 8, 12)];
    disclosureIndicator.image = [UIImage imageNamed:@"disclosureIndicator.png"];
    [_buttonInviteFriends addSubview:disclosureIndicator];
    UILabel *inviteFriendLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, (buttonHeight-1)/2.0-21/2.0, 120, 21)];
    inviteFriendLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:17.0f];
    inviteFriendLabel.text = NSLocalizedString(@"inviteFriend", nil);
    inviteFriendLabel.backgroundColor = [UIColor clearColor];
    inviteFriendLabel.textAlignment = NSTextAlignmentLeft;
    [_buttonInviteFriends addSubview:inviteFriendLabel];
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 325, 1)];
    line.backgroundColor = [UIColor colorWithWhite:235/255.0 alpha:1.0f];
    [_buttonInviteFriends addSubview:line];
    if (!IS_OS_7_OR_LATER) {
        [_buttonInviteFriends setBackgroundImage:[UIImage imageNamed:@"iOS6InviteFriendsBackground.png"] forState:UIControlStateNormal];
    }
    [_friendsTableView setTableHeaderView:_buttonInviteFriends];
    
    _friendsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _friendsTableView.contentInset = UIEdgeInsetsMake(0,0,65,0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (backFromInvite) {
        backFromInvite = NO;
        return;
    }
    if (!_contacts) {
        _contacts = [[NSMutableArray alloc] init];
    }
    if (!_allContacts) {
         _allContacts = [[NSMutableArray alloc] init];
    }
    didLoadFromStarting = YES;
    [self getAllQianLiFriends];
    int contactNumber = 0;
    for (NSArray *contactArray in _contacts) {
        if ([contactArray count] > 0) {
            contactNumber = 1;
            break;
        };
    }
    if (contactNumber == 0) {
        [self begionToUpdateContact];
        didLoadFromStarting = NO;
    }
    else{
        [_friendsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
    // 如果没有联系人则显示"提示邀请好友加入"界面
    [self showOrHideNoContacts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // Add additional code
    _countryName = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if(!_secondThread){
        _allContacts = nil;
    }
}

- (void)begionToUpdateContact
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if (netStatus != NotReachable) {
        if (_secondThread == nil) {
            NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(updateContactsFromServer) object:nil];
            _secondThread = thread;
            [_secondThread start];
            startingTime = [[NSDate date] timeIntervalSince1970];
        }
        else{
            double currentTime = [[NSDate date] timeIntervalSince1970];
            if ((currentTime - startingTime) > 600) {
                [_secondThread cancel];
            }
        }
    }
}

- (void)showOrHideNoContacts
{
    int contactNumber = 0;
    for (NSArray *contactArray in _contacts) {
        contactNumber = contactNumber + [contactArray count];
    }
    if (contactNumber > 0) {
        [self removeNoContacts];
    }
    else {
        [self showNoContacts];
    }
}

- (void)setCountryCodes
{
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                               @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    _countryCode = dictCodes;
}

-(void)getAddressBookPermission
{
    if (ABAddressBookRequestAccessWithCompletion) { // if in iOS 6
        // Request authorization to Address Book
        CFErrorRef error = NULL;
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        if (error) {
            if (addressBookRef != NULL) {
                CFRelease(addressBookRef);
            }
            return;
        }
        QianLiContactsViewController * __weak weakSelf = self;  // avoid capturing self in the block
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been granted, add the contact
                if (granted) {
                    [weakSelf loadAddressBook: addressBookRef];
                    if (addressBookRef != NULL) {
                        CFRelease(addressBookRef);
                    }
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add the contact
            [weakSelf loadAddressBook: addressBookRef];
            if (addressBookRef != NULL) {
                CFRelease(addressBookRef);
            }
        }
        else {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
            if (addressBookRef != NULL) {
                CFRelease(addressBookRef);
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"contactAlertTitle", nil) message:NSLocalizedString(@"contactAlertBody", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"iknow", nil) otherButtonTitles:nil];
            [alertView show];
        }
    }
    else{
        // if not in iOS 6
    }
}

- (void)loadAddressBook: (ABAddressBookRef) addressBooks
{
    // Create addressbook data model
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    
    for (NSInteger i = 0; i < CFArrayGetCount(allPeople); i++)
    {
        QianLiAddressBookItem *addressBook = [[QianLiAddressBookItem alloc] init];
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        if (person == nil) {
            continue;
        }
        NSString *qianliName = @"";
        NSString *nameString = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastNameString = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *abFullName = nil;
        if (ABRecordGetRecordType(person) != kABSourceType) {
            abFullName = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
        }
        
        if (abFullName) {
            qianliName = abFullName;
        }
        else{
            if (nameString) {
                qianliName = [NSString stringWithFormat:@"%@%@", qianliName, nameString];
            }
            if (lastNameString) {
                qianliName = [NSString stringWithFormat:@"%@ %@", qianliName, lastNameString];
            }
        }
        if (![qianliName isEqualToString:@""]) {
            addressBook.name = qianliName;
        }
        //Save thumbnail image - performance decreasing
        UIImage *personImage = nil;
        if (ABPersonHasImageData(person)) {
            if (ABPersonCopyImageDataWithFormat != NULL) {
                // iOS >= 4.1
                CFDataRef contactThumbnailData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
                if (contactThumbnailData != NULL) {
                    personImage = [UIImage imageWithData:(__bridge NSData*)contactThumbnailData];
                    CFRelease(contactThumbnailData);
                }
            }
        }
        else{
            //personImage = [UIImage imageNamed:@"blank.png"];
        }
        [addressBook setThumbnail: personImage];
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
            if (valuesRef != NULL) {
                valuesCount = ABMultiValueGetCount(valuesRef);
            }
            
            NSMutableArray *telephone = [NSMutableArray array];
            for (NSInteger k = 0; k < valuesCount; k++) {
                NSString *value = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        NSString *numStr = value;
                        NSCharacterSet* phoneChars = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
                        NSArray* words = [numStr componentsSeparatedByCharactersInSet :[phoneChars invertedSet]];
                        
                        NSString* strippedNumber = [words componentsJoinedByString:@""];
                        if ([strippedNumber length] < 3 ) {
                            continue;
                        }
                        if (addressBook.name == nil) {
                            addressBook.name = strippedNumber;
                        }
                        
                        if (![[strippedNumber substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"+"]) {
                            if (![[strippedNumber substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"00"]) {
                                if (_countryCode == nil) {
                                    [self setCountryCodes];
                                }
                                NSString *nationalCode = [_countryCode objectForKey:_countryName];
                                if (nationalCode) {
                                    strippedNumber = [NSString stringWithFormat:@"00%@%@",nationalCode,strippedNumber];
                                }
                            }
                        }
                        else{
                            // Change + to 00
                            strippedNumber = [strippedNumber substringFromIndex:1];
                            strippedNumber = [NSString stringWithFormat:@"00%@",strippedNumber];
                        }
                        
                        if (![strippedNumber isEqualToString:[UserDataAccessor getUserRemoteParty]]) {
                            [telephone addObject:strippedNumber];
                        }
                        addressBook.telAarry = telephone;
                        break;
                    }
                        
                    case 1: {// Email
                        addressBook.email = value;
                        break;
                    }
                }
            }
            if (valuesRef != NULL) {
                CFRelease(valuesRef);
            }
        }
        if (addressBook.name) {
            [addressBookTemp addObject:addressBook];
        }
    }
    if (allPeople != NULL) {
        CFRelease(allPeople);
    }
    // Sort data
    if (_allContacts == nil) {
        _allContacts = [NSMutableArray arrayWithCapacity:1];
    }
    else{
        [_allContacts removeAllObjects];
    }
    [self sortContacts:addressBookTemp sortedContacts:_allContacts];
}

- (void)sortContacts:(NSArray *)rawContacts sortedContacts:(NSMutableArray *)sortedContacts
{
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    for (QianLiContactsItem *addressBook in rawContacts) {
        NSInteger sect = [theCollation sectionForObject:addressBook
                                collationStringSelector:@selector(name)];
        addressBook.sectionNumber = sect;
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity: 1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (QianLiContactsItem *addressBook in rawContacts) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:addressBook.sectionNumber] addObject:addressBook];
    }
    
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(name)];
        [sortedContacts addObject:sortedSection];
    }
}

// Pass all contacts to server
- (void)sendContactsToServer
{
    if ([_allContacts count] == 0) {
        return;
    }
    
    BOOL first = YES;
    NSString *jsonRequest = @"[";
    for (int i = 0; i < [_allContacts count]; ++i) {
        NSArray *arr = (NSArray *)[_allContacts objectAtIndex:i];
        for (int j = 0; j < [arr count]; j++) {
            QianLiAddressBookItem *item = (QianLiAddressBookItem *)[arr objectAtIndex:j];
            if ([item.telAarry count] > 0) {
                for (int k = 0; k < [item.telAarry count]; ++k) {
                    if (first) {
                        jsonRequest = [NSString stringWithFormat:@"%@\"%@\"", jsonRequest, (NSString *)[item.telAarry objectAtIndex:k]];
                        first = NO;
                    }
                    else{
                        jsonRequest = [NSString stringWithFormat:@"%@,\"%@\"", jsonRequest, (NSString *)[item.telAarry objectAtIndex:k]];
                    }
                }
            }
        }
    }
    jsonRequest = [NSString stringWithFormat:@"%@]",jsonRequest];
    //CODEREVIEW: urlString 可以放在global文件里或者当前类文件的头部
    NSString *urlString= [NSString stringWithFormat:@"%@/users/whoisactive/.json", kBaseURL];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    
    NSData* requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    NSString* requestDataLengthString = [[NSString alloc] initWithFormat:@"%d", [requestData length]];
     
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPShouldUsePipelining:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];
    [request setTimeoutInterval:30.0];
    
    NSURLConnection *m_URLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (m_URLConnection == nil) {
        return;
    }
    while(!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// #programma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"connectionDidFinishLoading");
    _finished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *error;
    NSArray *JsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return;
    }
    [self selectFriendsFromContactsByNumber:JsonArray];
}

- (void)selectFriendsFromContactsByNumber:(NSArray *)numbers
{
    NSMutableArray *friends = [NSMutableArray array];
    for (int r = 0; r < [numbers count]; r ++) {
        BOOL getMatched = NO;
        for (int i = 0; i < [_allContacts count]; ++i) {
            NSArray *arr = [_allContacts objectAtIndex:i];
            
            for (int j = 0; j < [arr count]; ++j) {
                QianLiAddressBookItem *contact = (QianLiAddressBookItem *) [arr objectAtIndex:j];
                for (int k = 0; k < [contact.telAarry count]; ++k) {
                    NSString *numStr = (NSString *) [contact.telAarry objectAtIndex:k];
                    if ([numStr isEqualToString: (NSString *)[numbers objectAtIndex:r]]){
                        QianLiContactsItem *contactItem = [[QianLiContactsItem alloc] init];
                        contactItem.name = contact.name;
                        contactItem.tel = numStr;
                        contactItem.thumbnail = contact.thumbnail;
                        contactItem.email = contact.email;
                        [friends addObject:contactItem];
                        getMatched = YES;
                        break;
                    }
                }
                if (getMatched) {
                    break;
                }
            }
            if (getMatched) {
                break;
            }
        }
    }
    
    //add qianli robots
    QianLiContactsItem *contactItem = [[QianLiContactsItem alloc] init];
    contactItem.name = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:QianLiRobotNumber];
    contactItem.tel = QianLiRobotNumber;
    contactItem.thumbnail = [[QianLiContactsAccessor sharedInstance] getProfileForRemoteParty:QianLiRobotNumber];
    contactItem.email = @"";
    [friends addObject:contactItem];

    [_contacts removeAllObjects];
    [self sortContacts:friends sortedContacts:_contacts];
    NSArray *items = [[QianLiContactsAccessor sharedInstance] getAllContacts];
    for (int j = 0; j < [_contacts count]; ++j) {
        NSArray *arr = [_contacts objectAtIndex:j];
        for (int k = 0; k < [arr count]; ++k) {
            QianLiContactsItem *item = [arr objectAtIndex:k];
            for (int i = 0; i < [items count]; ++i){
                NSString *num = [(NSManagedObject *)[items objectAtIndex:i] valueForKey:@"number"];
                if ([num isEqualToString:item.tel]) {
                    UIImage *image = [UIImage imageWithData:[(NSManagedObject *)[items objectAtIndex:i] valueForKey:@"profile"]];
                    if (image) {
                        item.thumbnail = image;
                    }
                    if (!item.name) {
                        item.name = [(NSManagedObject *)[items objectAtIndex:i] valueForKey:@"name"];
                        if (!item.name) {
                            item.name = NSLocalizedString(@"unknownName", nil);
                        }
                    }
                    break;
                }
            }
        }
    }
    
    [self performSelectorOnMainThread:@selector(showOrHideNoContacts) withObject:nil waitUntilDone:NO];
    [_friendsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self updateQianLiContacts:items];
}

- (void)updateQianLiContacts:(NSArray *)items
{
    // delete the number that is not contained in _contacts
    for (int i = 0; i < [items count]; ++i){
        BOOL doHasIt = NO;
        NSString *num = [(NSManagedObject *)[items objectAtIndex:i] valueForKey:@"number"];
        for (int j = 0; j < [_contacts count]; ++j) {
            NSArray *arr = [_contacts objectAtIndex:j];
            for (int k = 0; k < [arr count]; ++k) {
                QianLiContactsItem *item = [arr objectAtIndex:k];
                if ([num isEqualToString:item.tel]) {
                    doHasIt = YES;
                    break;
                }
            }
            if (doHasIt) {
                break;
            }
        }
        if (!doHasIt) {
            [[QianLiContactsAccessor sharedInstance] performSelectorOnMainThread:@selector(deleteItemForRemoteParty:) withObject:num waitUntilDone:YES];
        }
    }
    
    // add new contact and update name
    for (int j = 0; j < [_contacts count]; ++j) {
        NSArray *arr = [_contacts objectAtIndex:j];
        for (int k = 0; k < [arr count]; ++k) {
            QianLiContactsItem *item = [arr objectAtIndex:k];
            BOOL doHasIt = NO;
            for (int i = 0; i < [items count]; ++i){
                 NSString *num = [(NSManagedObject *)[items objectAtIndex:i] valueForKey:@"number"];
                 if ([num isEqualToString:item.tel]) {
                     // update name
                     if (![item.name isEqualToString:[(NSManagedObject *)[items objectAtIndex:i] valueForKey:@"name"]]) {
                         NSArray *array= @[item.name, num];
                         [self performSelectorOnMainThread:@selector(updateNameToNumber:) withObject:array waitUntilDone:YES];
                         [self addToUpdateList:num name:item.name];
                     }
                     doHasIt = YES;
                     break;
                 }
            }
            if (!doHasIt) {
                NSArray *array= @[item, [NSNumber numberWithInteger: -1]];
                // insert new contacts
                [self performSelectorOnMainThread:@selector(insertItem:) withObject:array waitUntilDone:YES];
                [self addToUpdateList:item.tel name:item.name];
            }
        }
    }
    [self updateUserProfile];
}

- (void)addToUpdateList:(NSString *)number name:(NSString *)name
{
    if (!_updateArray) {
        _updateArray = [NSMutableArray array];
    }
    [_updateArray addObject:name];
    [_updateArray addObject:number];
}

// update user info functions
- (void)updateNameToNumber:(NSArray *)array
{
    if ([array count] < 2) {
        return;
    }
    NSString *name = [array objectAtIndex:0];
    NSString *num = [array objectAtIndex:1];
    [[QianLiContactsAccessor sharedInstance] updateName:name forNumber:num];
}

- (void)insertItem:(NSArray *)array
{
    if ([array count] < 2) {
        return;
    }
    QianLiContactsItem *item = [array objectAtIndex:0];
    NSInteger num = [[array objectAtIndex:1] integerValue];
    [[QianLiContactsAccessor sharedInstance] insertNewObject:item.name Email:item.email Profile:item.thumbnail Numbers:item.tel UpdateCounter:num];
}

- (void)updateUpdateTime:(NSArray *)array
{
    if ([array count] < 2) {
        return;
    }
    NSInteger updateTime = [[array objectAtIndex:0] integerValue];
    NSString *num = [array objectAtIndex:1];
    [[QianLiContactsAccessor sharedInstance] updateCounter:updateTime forNumber:num];
}

- (void)updateProfile:(NSArray *)array
{
    if ([array count] < 3) {
        return;
    }
    UIImage *image = [array objectAtIndex:0];
    NSInteger updateTime = [[array objectAtIndex:1] integerValue];
    NSString *num = [array objectAtIndex:2];
    [[QianLiContactsAccessor sharedInstance] updateProfile:image updateCounter:updateTime forNumber:num];
}

- (void)updateUserProfile
{
    NSArray *items = [[QianLiContactsAccessor sharedInstance] getAllContacts];
    for (int i = 0; i < [items count]; ++i) {
        NSManagedObject *object = [items objectAtIndex:i];
        NSString *number = [object valueForKey:@"number"];
        if ([number isEqualToString:QianLiRobotNumber]) {
            continue;
        }
        NSInteger counter = [(NSNumber *)[object valueForKey:@"updatecounter"] integerValue];
        [UserDataTransUtils getUserUpdateInfo:number Completion:^(NSInteger updateTime) {
            if (!(updateTime ==  counter)) {
                [UserDataTransUtils getUserData:[object valueForKey:@"number"] Completion:^(NSString *name, NSString *avatarURL) {
                    NSString *number = (NSString *)[object valueForKey:@"number"];
                    // If address has name, we use that name; otherwise, we use the name set by user
                    if (![object valueForKey:@"name"]) {
                        NSArray *array= @[name, number];
                        [self performSelectorOnMainThread:@selector(updateNameToNumber:) withObject:array waitUntilDone:YES];
                        [self updateAvatar:number withImage:nil withName:name];
                        [self addToUpdateList:number name:name];
                    }
                    // update profile and updateCounter
                    UIImage *image;
                    if (avatarURL) {
                       image = [UserDataTransUtils getImageAtPath:avatarURL];
                        if (image) {
                            NSArray *array = @[image, [NSNumber numberWithInteger:updateTime], number];
                            [self performSelectorOnMainThread:@selector(updateProfile:) withObject:array waitUntilDone:YES];
                            [self updateAvatar:number withImage:image withName:nil];
                        }
                    }
                    else
                    {
                        NSArray *array = @[[NSNumber numberWithInteger:updateTime], number];
                        [self performSelectorOnMainThread:@selector(updateUpdateTime:) withObject:array waitUntilDone:YES];
                    }
                }];
            }
        }];
    }
    if ([_updateArray count] > 0) {
        for (int i = 0; i < [_updateArray count] / 2; ++ i) {
            [UserDataTransUtils updateOneFriendName:[_updateArray objectAtIndex: 2 * i] number:[_updateArray objectAtIndex:2 * i + 1] completion:nil];
        }
        [_updateArray removeAllObjects];
    }
}

- (void)updateAvatar:(NSString *)number withImage:(UIImage *)image withName:(NSString *)name;
{
    for (int j = 0; j < [_contacts count]; ++j) {
        NSArray *array = [_contacts objectAtIndex:j];
        BOOL found = NO;
        for (int i = 0; i < [array count]; ++i) {
            QianLiContactsItem *contactItem = [array objectAtIndex:i];
            if ([contactItem.tel isEqualToString:number]) {
                if (image) {
                    contactItem.thumbnail = image;
                }
                if (name) {
                    contactItem.name = name;
                }
                found = YES;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:j];
                if (indexPath) {
                    [self performSelectorOnMainThread:@selector(updateContactsAt:) withObject:indexPath waitUntilDone:YES];
                }
                break;
            }
        }
        if (found) {
            break;
        }
    }
}

- (void)updateContactsAt:(NSIndexPath *)indexPath
{
    [_friendsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)getAllQianLiFriends
{
    NSArray *items = [[QianLiContactsAccessor sharedInstance] getAllContacts];
    NSMutableArray *qianliContacts = [NSMutableArray array];
    for (int i = 0; i < [items count]; ++i) {
        NSManagedObject *object = (NSManagedObject *) [items objectAtIndex:i];
        QianLiContactsItem *contactItem = [[QianLiContactsItem alloc] init];
        contactItem.name = (NSString *)[object valueForKey:@"name"];
        contactItem.thumbnail = [UIImage imageWithData: (NSData *)[object valueForKey:@"profile"]];
        contactItem.email = (NSString *)[object valueForKey:@"email"];
        contactItem.tel =  (NSString *)[object valueForKey:@"number"];
        [qianliContacts addObject:contactItem];
    }
    if (_contacts == nil){
        _contacts = [NSMutableArray array];
    }
    else{
        [_contacts removeAllObjects];
    }
    [self sortContacts:qianliContacts sortedContacts:_contacts];
}

- (void)restoreContacts
{
    if (_inviteController) {
        [_inviteController getAddressBookPermission];
    }
    else{
        [self getAllQianLiFriends];
    }
    [_friendsTableView reloadData];
}

- (void)clearContacts
{
    _allContacts = nil;
    _contacts = nil;
    if (_inviteController) {
        [_inviteController clearAddressItems];
    }
}

- (void)updateContactsFromServer
{
    // Update contacts
    // Setup the Network Info and create a CTCarrier object
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString *iosCC = [carrier isoCountryCode];
    if (iosCC != nil){
        _countryName = [iosCC uppercaseString];
    }
    else{
        //NSLog(@"No country code!");
    }
    
    // ipad如果没有sim卡, 也是无法拿到countryName的
    if (_countryName) {
        [self getAddressBookPermission];
        _finished = NO;
        [self sendContactsToServer];
    }
    else{
       // NSLog(@"no country code");
        // LLGG just for simulator
        [self getAddressBookPermission];
        _finished = NO;
        [self sendContactsToServer];
    }
}

- (IBAction)inviteFriends:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _inviteController = [storyBoard instantiateViewControllerWithIdentifier:@"InviteController"];
    _inviteController.title = @"Invite";
    if (_allContacts) {
        _inviteController.contacts = _allContacts;
    }
    _inviteController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:_inviteController animated:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    backFromInvite = YES;
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_contacts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_contacts objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactTableViewCell";
    
	ContactTableViewCell *contactCell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (contactCell == nil) {
		contactCell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withCheckBox:NO];
		contactCell.frame = CGRectMake(0.0, 0.0, 320.0, 44);
    }
    
    QianLiAddressBookItem *contact = nil;
    if ([_contacts count] <= indexPath.section) {
        return nil;
    }
    else{
        NSArray *array = [_contacts objectAtIndex:indexPath.section];
        if ([array count] <= indexPath.row) {
            return nil;
        }
    }
    
    contact = (QianLiAddressBookItem *)[[_contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (!contact.thumbnail) {
        contact.thumbnail = [UIImage imageNamed:@"blank.png"];
    }
    [contactCell setContactProfile: contact NeedIcon:YES];
    
    // Set seperator line
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44 - 1, 325, 1)];
    line.backgroundColor = [UIColor colorWithWhite:235/255.0 alpha:1.0f];
    [contactCell addSubview:line];
    
    return contactCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[_contacts objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[_contacts objectAtIndex:section] count] ? tableView.sectionHeaderHeight : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Call someone
    if ([_contacts count] <= indexPath.section) {
        return;
    }
    else{
        NSArray *array = [_contacts objectAtIndex:indexPath.section];
        if ([array count] <= indexPath.row) {
            return;
        }
    }
    QianLiContactsItem *item = (QianLiContactsItem *)[[_contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *remoteParty = item.tel;
    [[SipStackUtils sharedInstance] setRemotePartyNumber:remoteParty];
    [self callWithRemoteParty:remoteParty];
    [self.friendsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([_contacts count] <= indexPath.section) {
        return;
    }
    else{
        NSArray *array = [_contacts objectAtIndex:indexPath.section];
        if ([array count] <= indexPath.row) {
            return;
        }
    }
	QianLiAddressBookItem *addressBook = nil;
    addressBook = (QianLiAddressBookItem*)[[_contacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    BOOL checked = !addressBook.rowSelected;
    addressBook.rowSelected = checked;
    
    UITableViewCell *cell =[self.friendsTableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    [button setSelected:checked];
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastSection = [self getLastSection];
    if ([_contacts count] <= lastSection) {
        return;
    }
    if((indexPath.section == lastSection) && (indexPath.row == [[_contacts objectAtIndex:lastSection] count] - 1)){
        if (didLoadFromStarting){
            didLoadFromStarting = NO;
            [self begionToUpdateContact];
        }
    }
}

- (NSInteger)getLastSection
{
    NSInteger last = 0;
    for (int i = 0; i < [_contacts count]; ++i) {
        if ([[_contacts objectAtIndex:i] count] > 0){
            last = i;
        }
    }
    return last;
}

- (IBAction)callWithRemoteParty:(NSString *)_remotePartyPhoneNumber
{
    [[SipCallManager SharedInstance] makeQianliCallToRemote:_remotePartyPhoneNumber];
}

# pragma mark noContacts

- (void)showNoContacts
{
    if (!_noContactImageView) {
        UIImageView *noContactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(160-185/2.0, 140, 185, 150)];
        noContactImageView.image = [UIImage imageNamed:@"noContacts.png"];
        [self.view addSubview:noContactImageView];
        [self.view sendSubviewToBack:noContactImageView];
        _noContactImageView = noContactImageView;
    }
    
    if (!_noContactTitle) {
        UILabel *noContactTitle = [[UILabel alloc] initWithFrame:CGRectMake(160-50, 90, 100, 40)];
        noContactTitle.textAlignment = NSTextAlignmentCenter;
        noContactTitle.text = NSLocalizedString(@"noContact", nil);
        noContactTitle.textColor = [UIColor colorWithRed:63/255.0 green:63/255.0 blue:63/255.0 alpha:1.0f];
        noContactTitle.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16];
        [self.view addSubview:noContactTitle];
        [self.view sendSubviewToBack:noContactTitle];
        _noContactTitle = noContactTitle;
    }
    
    if (!_noContactBody) {
        UILabel *noContactBody = [[UILabel alloc] initWithFrame:CGRectMake(160-140, 290, 280, 80)];
        noContactBody.textAlignment = NSTextAlignmentCenter;
        noContactBody.text = NSLocalizedString(@"noContactBody", nil);
        noContactBody.textColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1.0f];
        noContactBody.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        [self.view addSubview:noContactBody];
        [self.view sendSubviewToBack:noContactBody];
        _noContactBody = noContactBody;
    }
 
    if (!_noContactBody2){
        UILabel *noContactBody2 = [[UILabel alloc] initWithFrame:CGRectMake(160-100, 305, 200, 80)];
        noContactBody2.textAlignment = NSTextAlignmentCenter;
        noContactBody2.text = NSLocalizedString(@"noContactBody2", nil);
        noContactBody2.textColor = [UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1.0f];
        noContactBody2.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:12];
        [self.view addSubview:noContactBody2];
        [self.view sendSubviewToBack:noContactBody2];
        _noContactBody2 = noContactBody2;
    }
}

- (void)removeNoContacts
{
    _noContactImageView.image = nil;
    [_noContactImageView removeFromSuperview];
    [_noContactTitle removeFromSuperview];
    [_noContactBody removeFromSuperview];
    [_noContactBody2 removeFromSuperview];
}

@end
