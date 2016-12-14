//
//  SFIAlmondCell.m
//  SecurifiApp
//
//  Created by K Murali Krishna on 13/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFIAlmondCell.h"
#import <Foundation/Foundation.h>

@interface SFIAlmondCell()

@property BOOL isOwnedAlmond;
@property NSMutableArray* ownedAlmondList;
@property NSMutableArray* sharedAlmondList;
@property CGRect frameValue;
@property float baseYCoordinate;
@property UIImageView *imgArrow;
@property UITextField* tfRenameAlmond;
@property SFIAlmondPlus *currentAlmond;
@property int indexPathRow;
@property CGRect bound;
@property NSString* changedAlmondName;
@property int nameChangedForAlmond;

@end


@implementation SFIAlmondCell

@synthesize tfRenameAlmond;
@synthesize nameChangedForAlmond;
@synthesize changedAlmondName;


#pragma mark - Data access

- (SFIAlmondPlus *)ownedAlmondAtIndexPathRow:(NSInteger)row {
    NSUInteger index = (NSUInteger) (row - 1);
    if (self.ownedAlmondList== nil || index >= [self.ownedAlmondList count]){
        return nil;
    }
    return self.ownedAlmondList[index];
}


- (SFIAlmondPlus *)sharedAlmondAtIndexPathRow:(NSInteger)row {
    NSUInteger index = (NSUInteger) (row - 1);
    NSLog(@"%luu is the length of ownedAlmondList",(unsigned long) (unsigned long)[_sharedAlmondList count]);
    if (index >= [_sharedAlmondList count]){
        return nil;
    }
    return self.sharedAlmondList[index];
}

-(void) onUnlinkAlmondClicked:(id)sender {
    [self.delegate onUnlinkAlmondClicked:sender];
}

-(void) onInviteClicked:(id) sender {
    [self.delegate onInviteClicked:sender];
}

-(void) onRemoveSharedAlmondClicked:(id)sender {
    [self.delegate onRemoveSharedAlmondClicked:sender];
}

-(void)onEmailRemoveClicked: (id)sender {
    [self.delegate onEmailRemoveClicked:sender];
}

- (void)textFieldFinished:(UITextField*) tfName {
    changedAlmondName = tfName.text;
    [tfName resignFirstResponder];
}

-(void)textFieldDidChange:(UITextField *)tfName {
    changedAlmondName = tfName.text;
}

- (void) onAlmondClicked: (id) sender {
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;
    
    SFIAlmondPlus *currentAlmond;
    if(self.isOwnedAlmond){
        currentAlmond = [self ownedAlmondAtIndexPathRow:index];
        //Reload only that particular row
    }else{
        currentAlmond = [self sharedAlmondAtIndexPathRow:index];
        //DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
        index = (int) (index + [self.ownedAlmondList count]);
    }
    currentAlmond.isExpanded = !currentAlmond.isExpanded;
    [self.delegate reloadTable: (int)index];
}

-(void) isExapanded{
    if(self.isOwnedAlmond){
        float expandedLabelSize = EXPANDED_OWNED_ALMOND_ROW_HEIGHT;
        if ([_currentAlmond.accessEmailIDs count] > 0) {
            expandedLabelSize = expandedLabelSize + 30 + ([_currentAlmond.accessEmailIDs count] * 25);
        }
        self.frame = CGRectMake(10, 5, _frameValue.size.width - 20, expandedLabelSize - 10);
    }else{
        self.frame = CGRectMake(10, 5, _frameValue.size.width - 20, EXPANDED_SHARED_ALMOND_ROW_HEIGHT - 10);
    }
    _imgArrow.image = [UIImage imageNamed:UP_ARROW];
    
    //Almond Name
    UILabel *lblAlmondTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, _baseYCoordinate, 120, 30)];
    lblAlmondTitle.backgroundColor = [UIColor clearColor];
    lblAlmondTitle.textColor = [UIColor whiteColor];
    if(self.isOwnedAlmond){
        [lblAlmondTitle setFont:[UIFont standardUITextFieldFont]];
        lblAlmondTitle.text = NSLocalizedString(ACCOUNTS_OWNEDALMOND_LABEL_DEVICENAME, DEVICE_NAME);
    }else{
        [lblAlmondTitle setFont:[UIFont securifiBoldFont:13]];
        lblAlmondTitle.text = NSLocalizedString(ACCOUNTS_SHAREDALMOND_LABEL_DEVICENAME, DEVICE_NAME);
    }
    lblAlmondTitle.textAlignment = NSTextAlignmentLeft;
    [self addSubview:lblAlmondTitle];
    
    UIButton *btnUnlinkAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUnlinkAlmond.frame = CGRectMake(_frameValue.size.width - 160, _baseYCoordinate, 130, 30);
    btnUnlinkAlmond.backgroundColor = [UIColor clearColor];
    if(self.isOwnedAlmond)
        [btnUnlinkAlmond setTitle:NSLocalizedString(ACCOUNTS_OWNEDALMOND_BUTTON_UNLINK, UNLINK) forState:UIControlStateNormal];
    else
        [btnUnlinkAlmond setTitle:NSLocalizedString(ACCOUNTS_SHAREDALMOND_BUTTON_REMOVE, REMOVE) forState:UIControlStateNormal];
    [btnUnlinkAlmond.titleLabel setFont:[UIFont standardUIButtonFont]];
    [btnUnlinkAlmond setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
    btnUnlinkAlmond.tag = _indexPathRow;
    btnUnlinkAlmond.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    if(self.isOwnedAlmond)
        [btnUnlinkAlmond addTarget:self action:@selector(onUnlinkAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    else
        [btnUnlinkAlmond addTarget:self action:@selector(onRemoveSharedAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnUnlinkAlmond];
    
    _baseYCoordinate += 25;
    
    CGFloat rename_button_width = 130;
    CGFloat rename_textfield_width = CGRectGetWidth(_bound) - 10 - rename_button_width - 30;
    tfRenameAlmond = [[UITextField alloc] initWithFrame:CGRectMake(10, _baseYCoordinate, rename_textfield_width - 10, 30)];
    if(self.isOwnedAlmond)
        tfRenameAlmond.placeholder = NSLocalizedString(ACCOUNTS_OWNEDALMOND_TEXTFIELD_PLACEHOLDER, ALMOND_NAME);
    else{
        tfRenameAlmond.placeholder = NSLocalizedString(ACCOUNTS_SHAREDALMOND_TEXTFIELD_PLACEHOLDER_ALMONDNAME, ALMOND_NAME);
    }
    [tfRenameAlmond setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
    tfRenameAlmond.text = _currentAlmond.almondplusName;
    tfRenameAlmond.textAlignment = NSTextAlignmentLeft;
    tfRenameAlmond.textColor = [UIColor whiteColor];
    tfRenameAlmond.font = [UIFont standardUITextFieldFont];
    tfRenameAlmond.tag = _indexPathRow;
    [tfRenameAlmond setReturnKeyType:UIReturnKeyDone];
    tfRenameAlmond.enabled = FALSE;
    [tfRenameAlmond addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [tfRenameAlmond addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self addSubview:tfRenameAlmond];
    
    
    UIButton *btnChangeAlmondName = [UIButton buttonWithType:UIButtonTypeCustom];
    btnChangeAlmondName.frame = CGRectMake(_frameValue.size.width - 160, _baseYCoordinate, rename_button_width, 30);
    btnChangeAlmondName.backgroundColor = [UIColor clearColor];
    if(self.isOwnedAlmond){
        btnChangeAlmondName.titleLabel.font = [UIFont standardUIButtonFont];
        [btnChangeAlmondName setTitle:NSLocalizedString(ACCOUNTS_OWNEDALMOND_BUTTON_RENAMEDALMOND, RENAME_ALMOND) forState:UIControlStateNormal];
    }else{
        [btnChangeAlmondName setTitle:NSLocalizedString(ACCOUNTS_SHAREDALMOND_BUTTON_RENAMEALMOND, RENAME_ALMOND) forState:UIControlStateNormal];
        [btnChangeAlmondName.titleLabel setFont:[UIFont standardUIButtonFont]];
    }
    [btnChangeAlmondName setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
    btnChangeAlmondName.tag = _indexPathRow;
    btnChangeAlmondName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [btnChangeAlmondName addTarget:self action:@selector(onChangeAlmondNameClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnChangeAlmondName];
    
    _baseYCoordinate += 30;
    UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, _baseYCoordinate, _frameValue.size.width - 35, 1)];
    imgLine2.image = [UIImage imageNamed:LINE];
    imgLine2.alpha = 0.2;
    [self addSubview:imgLine2];
    
    if(self.isOwnedAlmond){
        if ([_currentAlmond.accessEmailIDs count] > 0) {
            _baseYCoordinate += 5;
            UILabel *lblEmailTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, _baseYCoordinate, 120, 30)];
            lblEmailTitle.backgroundColor = [UIColor clearColor];
            lblEmailTitle.textColor = [UIColor whiteColor];
            [lblEmailTitle setFont:[UIFont securifiBoldFont:13]];
            lblEmailTitle.text = NSLocalizedString(ACCOUNTS_OWNEDALMOND_LABEL_ACCESSEMAIL, ACCESS_EMAIL);
            lblEmailTitle.textAlignment = NSTextAlignmentLeft;
            [self addSubview:lblEmailTitle];
            
            //Show text field for each email id
            
            for (int index = 0; index < [_currentAlmond.accessEmailIDs count]; index++) {
                _baseYCoordinate += 25;
                NSString *currentEmail = _currentAlmond.accessEmailIDs[index];
                UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, _baseYCoordinate, 220, 30)];
                lblEmail.backgroundColor = [UIColor clearColor];
                lblEmail.textColor = [UIColor whiteColor];
                [lblEmail setFont:[UIFont standardUITextFieldFont]];
                lblEmail.text = currentEmail;
                lblEmail.textAlignment = NSTextAlignmentLeft;
                [self addSubview:lblEmail];
                
                UIButton *btnEmailRemove = [UIButton buttonWithType:UIButtonTypeCustom];
                btnEmailRemove.frame = CGRectMake(160, _baseYCoordinate, 130, 30);
                btnEmailRemove.backgroundColor = [UIColor clearColor];
                [btnEmailRemove setTitle:NSLocalizedString(ACCOUNTS_OWNEDALMOND_BUTTON_REMOVE, REMOVE) forState:UIControlStateNormal];
                [btnEmailRemove.titleLabel setFont:[UIFont standardUIButtonFont]];
                btnEmailRemove.tag = index;
                btnEmailRemove.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [btnEmailRemove addTarget:self action:@selector(onEmailRemoveClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btnEmailRemove];
            }
            
            _baseYCoordinate += 30;
            UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, _baseYCoordinate, _frameValue.size.width - 35, 1)];
            imgLine.image = [UIImage imageNamed:LINE];
            imgLine.alpha = 0.2;
            [self addSubview:imgLine];
        }
        
        _baseYCoordinate += 12;
        
        UIButton *btnInvite = [[UIButton alloc] init];
        btnInvite.frame = CGRectMake(_frameValue.size.width / 2 - 60, _baseYCoordinate, 110, 30);
        btnInvite.backgroundColor = [UIColor clearColor];
        [[btnInvite layer] setBorderWidth:2.0f];
        [[btnInvite layer] setBorderColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0].CGColor];
        [btnInvite setTitle:NSLocalizedString(ACCOUNTS_OWNED_BUTTON_INVITEMORE,INVITE_MORE) forState:UIControlStateNormal];
        [btnInvite setTitleColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0] forState:UIControlStateNormal];
        [btnInvite.titleLabel setFont:[UIFont securifiBoldFont:13]];
        btnInvite.tag = _indexPathRow;
        btnInvite.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btnInvite addTarget:self action:@selector(onInviteClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnInvite];
    }
}


-(void) onChangeAlmondNameClicked: (id)sender {
    BOOL ownedAlmond;
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;
    
    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_DONE, DONE)]) {
        [tfRenameAlmond resignFirstResponder];
        if(ownedAlmond)
            [btn setTitle:NSLocalizedString(ACCOUNTS_OWNEDALMOND_BUTTON_RENAMEDALMOND, RENAME_ALMOND) forState:UIControlStateNormal];
        else
            [btn setTitle:NSLocalizedString(ACCOUNTS_SHAREDALMOND_BUTTON_RENAMEALMOND, RENAME_ALMOND) forState:UIControlStateNormal];
        tfRenameAlmond.enabled = FALSE;
        SFIAlmondPlus *currentAlmond;
        if(ownedAlmond)
            currentAlmond = [self ownedAlmondAtIndexPathRow:index];
        else
            currentAlmond = [self sharedAlmondAtIndexPathRow:index];
        
        if (changedAlmondName.length == 0) {
            return;
        }
        else if (changedAlmondName.length > 32) {
            [self.delegate showToastForMoreThan32Chars];
        }
        if(ownedAlmond)
            nameChangedForAlmond = NAME_CHANGED_OWNED_ALMOND;
        else
            nameChangedForAlmond = NAME_CHANGED_SHARED_ALMOND;
        
        NSArray *data = @[@"AlmondNameChange", currentAlmond.almondplusMAC, changedAlmondName];
        NSArray *localizedStrings = @[ACCOUNTS_HUD_CHANGEALMOND, CHANGE_ALMOND_NAME];
        [self.delegate sendRequest:(CommandType*)CommandType_ALMOND_NAME_CHANGE_REQUEST withData:data withLocalizedStrings:localizedStrings];
        [self.delegate onChangeAlmondNameClicked:changedAlmondName nameChangeValue:nameChangedForAlmond];
    }
    else {
        [btn setTitle:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_DONE, DONE) forState:UIControlStateNormal];
        tfRenameAlmond.enabled = TRUE;
        [tfRenameAlmond becomeFirstResponder];
    }
}


-(void) isNotExpanded{
    self.frame = CGRectMake(10, 5, _frameValue.size.width - 20, 110);
    
    _imgArrow.image = [UIImage imageNamed:DOWN_ARROW];
    
    _baseYCoordinate += 5;
    
    UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, _baseYCoordinate, _frameValue.size.width - 30, 20)];
    lblStatus.backgroundColor = [UIColor clearColor];
    lblStatus.textColor = [UIColor whiteColor];
    [lblStatus setFont:[UIFont securifiBoldFont:14]];
    if(self.isOwnedAlmond)
        lblStatus.text = NSLocalizedString(ACCOUNTS_OWNEDALMOND_LABEL_YOUOWNTHISALMOND, YOU_OWN_THIS_ALMOND);
    else{
        lblStatus.text = NSLocalizedString(ACCOUNTS_SHAREDALMOND_LABEL_SHAREDWITHYOUBY, SHARED_WITH_YOU_BY);
    }
    lblStatus.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblStatus];
    _baseYCoordinate += 20;
    
    UILabel *lblShared = [[UILabel alloc] initWithFrame:CGRectMake(10, _baseYCoordinate, _frameValue.size.width - 30, 30)];
    lblShared.backgroundColor = [UIColor clearColor];
    lblShared.textColor = [UIColor whiteColor];
    [lblShared setFont:[UIFont standardUITextFieldFont]];
    
    if(self.isOwnedAlmond)
        lblShared.text = [NSString stringWithFormat:NSLocalizedString(ACCOUNTS_OWNEDALMOND_LABEL_SHAREDWITHOTHERS, @"Shared with %d other(s)"), (int) [_currentAlmond.accessEmailIDs count]];
    else{
        lblShared.text = _currentAlmond.ownerEmailID;
    }
    
    lblShared.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblShared];
}

-(SFIAlmondCell*)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}

-(void)initWith:(CGRect)frame withBound:(CGRect)bound isOwnedAlmond:(BOOL)isOwnedAlmond listRow:(int)indexPathRow ownedAlmondList:(NSMutableArray*)ownedList sharedAlmondList:(NSMutableArray*)sharedList{
    
    _bound = bound;
    _indexPathRow = indexPathRow;
    _frameValue = frame;
    _ownedAlmondList = ownedList;
    _sharedAlmondList = sharedList;
    _isOwnedAlmond = isOwnedAlmond;
    _baseYCoordinate = 0;
    
    self.userInteractionEnabled = TRUE;
    if(self.isOwnedAlmond)
        self.backgroundColor = [UIColor colorWithRed:0.0 / 255.0 green:168.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];
    else
        self.backgroundColor = [UIColor colorWithRed:0.0 / 255.0 green:203.0 / 255.0 blue:124.0 / 255.0 alpha:1.0];
    
    if(self.isOwnedAlmond)
        _currentAlmond = [self ownedAlmondAtIndexPathRow:indexPathRow];
    else{
        indexPathRow = indexPathRow - (int) [self.ownedAlmondList count];
        _currentAlmond = [self sharedAlmondAtIndexPathRow:indexPathRow];
    }
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, _baseYCoordinate + 7, frame.size.width - 90, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont securifiLightFont:25];
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.text = _currentAlmond.almondplusName;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblTitle];
    
    _imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 60, 12, 23, 23)];
    [self addSubview:_imgArrow];
    
    UIButton *btnExpandOwnedRow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExpandOwnedRow.frame = CGRectMake(frame.size.width - 80, _baseYCoordinate + 5, 50, 50);
    btnExpandOwnedRow.backgroundColor = [UIColor clearColor];
    if(self.isOwnedAlmond){
        NSLog(@"%d is the type of almond inside", self.isOwnedAlmond);
        btnExpandOwnedRow.tag = 0;
        [btnExpandOwnedRow addTarget:self action:@selector(onAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        btnExpandOwnedRow.tag = 1;
        NSLog(@"%d is the type of almond inside", self.isOwnedAlmond);
        [btnExpandOwnedRow addTarget:self action:@selector(onAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    btnExpandOwnedRow.tag = indexPathRow;
    [self addSubview:btnExpandOwnedRow];
    
    _baseYCoordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, _baseYCoordinate, frame.size.width - 35, 1)];
    imgLine.image = [UIImage imageNamed:LINE];
    imgLine.alpha = 0.5;
    [self addSubview:imgLine];
    _baseYCoordinate += 5;
    
    if (!_currentAlmond.isExpanded) {
        [self isNotExpanded];
    }
    else {
        [self isExapanded];
    }
    
}

@end
