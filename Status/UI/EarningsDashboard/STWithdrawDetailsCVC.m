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
@interface STWithdrawDetailsCVC ()<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray <STWDSectionViewModel *> *sectionsArray;
@property (nonatomic, strong) STWithdrawDetailsObj *withdrawDetailsObj;

@end

@implementation STWithdrawDetailsCVC

static NSString * const inputCellIdentifier = @"STWithdrawDetailsInputCell";
static NSString * const headerIdentifier = @"STWithdrawDetailsHeader";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
//    [self.collectionView registerClass:[STWithdrawDetailsInputCell class] forCellWithReuseIdentifier:inputCellIdentifier];
//    [self.collectionView registerClass:[STWithdrawDetailsHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerIdentifier];
    
    __weak STWithdrawDetailsCVC *weakSelf = self;
    [STDataAccessUtils getUserWithdrawDetailsWithCompletion:^(NSArray *objects, NSError *error) {
        if ([objects count]) {
            weakSelf.withdrawDetailsObj = [objects firstObject];
            //no data saved yet
            if (!weakSelf.withdrawDetailsObj) {
                weakSelf.withdrawDetailsObj = [STWithdrawDetailsObj new];
            }
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
    STWDSectionViewModel *sectionVM = _sectionsArray[indexPath.section];
    STWDInputViewModel *inputVM = [sectionVM inputVMAtIndex:indexPath.item];
    [cell configureWithInputViewModel:inputVM];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 55.f);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        STWithdrawDetailsHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerIdentifier forIndexPath:indexPath];
        STWDSectionViewModel *sectionVM = _sectionsArray[indexPath.section];
        [header configureWithSectionViewModel:sectionVM];
        
        return header;
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 35.f);
}

-(void)save{
    //TODO: add the validations
    
    [STDataAccessUtils postUserWithdrawDetails:_withdrawDetailsObj
                                withCompletion:^(NSError *error) {
                                    NSLog(@"Error: %@", error);
                                }];
}
@end
