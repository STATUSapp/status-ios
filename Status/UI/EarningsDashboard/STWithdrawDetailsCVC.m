//
//  STWithdrawDetailsCVC.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWithdrawDetailsCVC.h"
#import "STWDSectionViewModel.h"
#import "STWithdrawDetailsObj.h"
#import "STDataAccessUtils.h"

#import "STWithdrawDetailsHeader.h"
#import "STWithdrawDetailsInputCell.h"

#import "STIndexPathTextField.h"
#import "STNavigationService.h"

typedef NS_ENUM(NSUInteger, STWithdrawDetailsSection) {
    STWithdrawDetailsSectionPersonal = 0,
    STWithdrawDetailsSectionCompany,
    STWithdrawDetailsSectionCount,
};
typedef NS_ENUM(NSUInteger, STPersonalDetailsItem) {
    STPersonalDetailsItemFirstName,
    STPersonalDetailsItemLastName,
    STPersonalDetailsItemEmail,
    STPersonalDetailsItemPhoneNumber,
    STPersonalDetailsItemCount
};
typedef NS_ENUM(NSUInteger, STCompanyDetailsItem) {
    STCompanyDetailsItemName,
    STCompanyDetailsItemVATNumber,
    STCompanyDetailsItemRegisterNumber,
    STCompanyDetailsItemCountry,
    STCompanyDetailsItemCity,
    STCompanyDetailsItemAddress,
    STCompanyDetailsItemIBAN,
    STCompanyDetailsItemCount
};
@interface STWithdrawDetailsCVC ()<UICollectionViewDelegateFlowLayout, UITextFieldDelegate>

@property (nonatomic, strong) NSArray <STWDSectionViewModel *> *sectionsArray;
@property (nonatomic, strong) STWithdrawDetailsObj *withdrawDetailsObj;
@property (nonatomic, strong) UITextField *currentField;
@end

@implementation STWithdrawDetailsCVC

static NSString * const inputCellIdentifier = @"STWithdrawDetailsInputCell";
static NSString * const headerIdentifier = @"STWithdrawDetailsHeader";

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak STWithdrawDetailsCVC *weakSelf = self;
    [STDataAccessUtils getUserWithdrawDetailsWithCompletion:^(NSArray *objects, NSError *error) {
        if ([objects count]) {
            weakSelf.withdrawDetailsObj = [objects firstObject];
            //no data saved yet
            if (!weakSelf.withdrawDetailsObj) {
                weakSelf.withdrawDetailsObj = [STWithdrawDetailsObj new];
            }
            
//#ifdef DEBUG
//            weakSelf.withdrawDetailsObj = [STWithdrawDetailsObj mockObject];
//#endif
            
            [weakSelf buildViewModels];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buildViewModels{
    //personal section
    STWDInputViewModel *firstNameVM = [[STWDInputViewModel alloc]
                                       initWithName:NSLocalizedString(@"First Name", nil)
                                       value:_withdrawDetailsObj.firstname
                                       placehodler:NSLocalizedString(@"Enter First Name", nil)];
    STWDInputViewModel *lastNameVM = [[STWDInputViewModel alloc]
                                      initWithName:NSLocalizedString(@"Last Name", nil)
                                      value:_withdrawDetailsObj.lastname
                                      placehodler:NSLocalizedString(@"Enter Last Name", nil)];
    STWDInputViewModel *emailVM = [[STWDInputViewModel alloc]
                                   initWithName:NSLocalizedString(@"Email Address", nil)
                                   value:_withdrawDetailsObj.email
                                   placehodler:NSLocalizedString(@"Enter Email Address", nil)];
    STWDInputViewModel *phoneNumberVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"Phone Number", nil)
                                         value:_withdrawDetailsObj.phone_number
                                         placehodler:NSLocalizedString(@"Enter Phone Number", nil)];
    NSMutableArray *personalSectionItems = [[NSMutableArray alloc] initWithCapacity:STPersonalDetailsItemCount];
    [personalSectionItems insertObject:firstNameVM atIndex:STPersonalDetailsItemFirstName];
    [personalSectionItems insertObject:lastNameVM atIndex:STPersonalDetailsItemLastName];
    [personalSectionItems insertObject:emailVM atIndex:STPersonalDetailsItemEmail];
    [personalSectionItems insertObject:phoneNumberVM atIndex:STPersonalDetailsItemPhoneNumber];
    STWDSectionViewModel *personalSectionVM = [[STWDSectionViewModel alloc]
                                               initWithName:NSLocalizedString(@"PERSONAL DETAILS", nil)
                                               andInputs:personalSectionItems];
    //company section
    STWDInputViewModel *companyNameVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"Company Name", nil)
                                         value:_withdrawDetailsObj.company
                                         placehodler:NSLocalizedString(@"Enter company name", nil)];
    STWDInputViewModel *VATNoVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"VAT No.", nil)
                                         value:_withdrawDetailsObj.vat_number
                                         placehodler:NSLocalizedString(@"Enter VAT Number", nil)];
    STWDInputViewModel *registerNoVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"Reg. No.", nil)
                                         value:_withdrawDetailsObj.register_number
                                         placehodler:NSLocalizedString(@"Enter Register Number", nil)];
    STWDInputViewModel *countryVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"Country", nil)
                                         value:_withdrawDetailsObj.country
                                         placehodler:NSLocalizedString(@"Enter Country", nil)];
    STWDInputViewModel *cityVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"City", nil)
                                         value:_withdrawDetailsObj.city
                                         placehodler:NSLocalizedString(@"Enter City", nil)];
    STWDInputViewModel *addressVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"Address", nil)
                                         value:_withdrawDetailsObj.address
                                         placehodler:NSLocalizedString(@"Enter Address", nil)];
    STWDInputViewModel *IBANVM = [[STWDInputViewModel alloc]
                                         initWithName:NSLocalizedString(@"IBAN", nil)
                                         value:_withdrawDetailsObj.iban
                                         placehodler:NSLocalizedString(@"Enter IBAN", nil)];

    NSMutableArray *companySectionItems = [[NSMutableArray alloc] initWithCapacity:STCompanyDetailsItemCount];
    [companySectionItems insertObject:companyNameVM atIndex:STCompanyDetailsItemName];
    [companySectionItems insertObject:VATNoVM atIndex:STCompanyDetailsItemVATNumber];
    [companySectionItems insertObject:registerNoVM atIndex:STCompanyDetailsItemRegisterNumber];
    [companySectionItems insertObject:countryVM atIndex:STCompanyDetailsItemCountry];
    [companySectionItems insertObject:cityVM atIndex:STCompanyDetailsItemCity];
    [companySectionItems insertObject:addressVM atIndex:STCompanyDetailsItemAddress];
    [companySectionItems insertObject:IBANVM atIndex:STCompanyDetailsItemIBAN];
    
    STWDSectionViewModel *companySectionVM = [[STWDSectionViewModel alloc]
                                            initWithName:NSLocalizedString(@"COMPANY DETAILS", nil)
                                            andInputs:companySectionItems];
    
    _sectionsArray = [NSArray arrayWithObjects:personalSectionVM, companySectionVM, nil];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_sectionsArray count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    STWDSectionViewModel *sectionVM = _sectionsArray[section];
    return [sectionVM.inputs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STWithdrawDetailsInputCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:inputCellIdentifier forIndexPath:indexPath];
    STWDInputViewModel *inputVM = [self inputVMForIndexPath:indexPath];
    [cell configureWithInputViewModel:inputVM andIndexPath:indexPath];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 75.f);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        STWithdrawDetailsHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        STWDSectionViewModel *sectionVM = _sectionsArray[indexPath.section];
        [header configureWithSectionViewModel:sectionVM];
        
        return header;
    }
    return [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 35.f);
}

- (STWDInputViewModel *)inputVMForIndexPath:(NSIndexPath *)indexPath{
    STWDSectionViewModel *sectionVM = _sectionsArray[indexPath.section];
    STWDInputViewModel *inputVM = [sectionVM inputVMAtIndex:indexPath.item];
    return inputVM;
}

-(BOOL)validate{
    for (STWDSectionViewModel *wdSection in _sectionsArray) {
        for (STWDInputViewModel *wdInput in wdSection.inputs) {
            if (wdInput.inputValue.length == 0) {
                return NO;
            }
        }
    }
    
    return YES;
}

-(void)save{
    [_currentField resignFirstResponder];
//    if (![self validate]) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please fill in all input in order to receive the payments.", nil) preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil]];
//        [self.parentViewController presentViewController:alert animated:YES completion:nil];
//        return;
//    }
    
    STWithdrawDetailsObj *savedObject = [STWithdrawDetailsObj new];
    STWDSectionViewModel *personalSectionVM = _sectionsArray[STWithdrawDetailsSectionPersonal];
    STWDInputViewModel *firstNameInput = personalSectionVM.inputs[STPersonalDetailsItemFirstName];
    savedObject.firstname = firstNameInput.inputValue;
    STWDInputViewModel *lastNameInput = personalSectionVM.inputs[STPersonalDetailsItemLastName];
    savedObject.lastname = lastNameInput.inputValue;
    STWDInputViewModel *emailInput = personalSectionVM.inputs[STPersonalDetailsItemEmail];
    savedObject.email = emailInput.inputValue;
    STWDInputViewModel *phoneNumberInput = personalSectionVM.inputs[STPersonalDetailsItemPhoneNumber];
    savedObject.phone_number = phoneNumberInput.inputValue;
    STWDSectionViewModel *companySectionVM = _sectionsArray[STWithdrawDetailsSectionCompany];
    STWDInputViewModel *companyNameInput = companySectionVM.inputs[STCompanyDetailsItemName];
    savedObject.company = companyNameInput.inputValue;
    STWDInputViewModel *vatInput = companySectionVM.inputs[STCompanyDetailsItemVATNumber];
    savedObject.vat_number = vatInput.inputValue;
    STWDInputViewModel *registerNumberInput = companySectionVM.inputs[STCompanyDetailsItemRegisterNumber];
    savedObject.register_number = registerNumberInput.inputValue;
    STWDInputViewModel *countryInput = companySectionVM.inputs[STCompanyDetailsItemCountry];
    savedObject.country = countryInput.inputValue;
    STWDInputViewModel *cityInput = companySectionVM.inputs[STCompanyDetailsItemCity];
    savedObject.city = cityInput.inputValue;
    STWDInputViewModel *addressInput = companySectionVM.inputs[STCompanyDetailsItemAddress];
    savedObject.address = addressInput.inputValue;
    STWDInputViewModel *ibanInput = companySectionVM.inputs[STCompanyDetailsItemIBAN];
    savedObject.iban = ibanInput.inputValue;
    
    [STDataAccessUtils postUserWithdrawDetails:savedObject
                                withCompletion:^(NSError *error) {
                                    NSLog(@"Error: %@", error);

                                    __weak STWithdrawDetailsCVC *weakSelf = self;
                                    UIAlertController *alert = nil;
                                    NSString *alertMessage = nil;
                                    NSString *extraMessage = nil;
                                    if (!error) {
                                        alertMessage = @"Your withdraw details were saved.";
                                        [weakSelf.parentViewController.navigationController popViewControllerAnimated:YES];
                                    }else{
                                        alertMessage = @"Your withdraw details were not saved.";
                                        if (error.code == STWebservicesUnprocessableEntity) {
                                            extraMessage = [weakSelf requiredFieldsFromError:error];
                                        }
                                    }
                                    
                                    NSString *finaleAlertMessage = alertMessage;
                                    if (extraMessage) {
                                        finaleAlertMessage = [NSString stringWithFormat:@"%@\n%@", alertMessage, extraMessage];
                                    }
                                    
                                    alert = [UIAlertController alertControllerWithTitle:nil message:finaleAlertMessage preferredStyle:UIAlertControllerStyleAlert];
                                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                    [[CoreManager navigationService] presentAlertController:alert];

                                }];
}

-(NSString *)requiredFieldsFromError:(NSError *)error{
    
    NSDictionary * response = nil;
    NSData * data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    if (data) {
         response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    NSArray *requiredFields = [response allKeys];
    return [NSString stringWithFormat:@"Required fields: %@.", [requiredFields componentsJoinedByString:@", "]];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(STIndexPathTextField *)textField{
    NSIndexPath *indexPath = textField.indexPath;
    _currentField = nil;
    STWDInputViewModel *inputVM = [self inputVMForIndexPath:indexPath];
    [inputVM updateValue:textField.text];
    
    STWDSectionViewModel *personalSectionVM = _sectionsArray[STWithdrawDetailsSectionPersonal];
    STWDSectionViewModel *companySectionVM = _sectionsArray[STWithdrawDetailsSectionCompany];

    BOOL hasChanges = [personalSectionVM hasChanges] || [companySectionVM hasChanges];
    [_delegate childCVCHasChanges:hasChanges];
}

-(void)textFieldDidBeginEditing:(STIndexPathTextField *)textField{
    _currentField = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end

/*
 STWithdrawDetailsSection section = indexPath.section;
 switch (section) {
 case STWithdrawDetailsSectionPersonal:{
 STPersonalDetailsItem item = indexPath.item;
 switch (item) {
 case STPersonalDetailsItemFirstName:{
 
 }
 break;
 case STPersonalDetailsItemLastName:{
 
 }
 break;
 case STPersonalDetailsItemEmail:{
 
 }
 break;
 case STPersonalDetailsItemPhoneNumber:{
 
 }
 break;
 
 default:
 break;
 }
 }
 break;
 case STWithdrawDetailsSectionCompany:{
 STCompanyDetailsItem item = indexPath.item;
 switch (item) {
 case STCompanyDetailsItemName:{
 
 }
 break;
 case STCompanyDetailsItemCity:{
 
 }
 break;
 case STCompanyDetailsItemIBAN:{
 
 }
 break;
 case STCompanyDetailsItemAddress:{
 
 }
 break;
 case STCompanyDetailsItemCountry:{
 
 }
 break;
 case STCompanyDetailsItemVATNumber:{
 
 }
 break;
 case STCompanyDetailsItemRegisterNumber:{
 
 }
 break;
 
 default:
 break;
 }
 }
 break;
 default:
 break;
 }
 */
