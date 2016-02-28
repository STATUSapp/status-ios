//
//  STContactsDataProcessor.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@class STAddressBookContact;

typedef NS_ENUM(NSUInteger,STContactsProcessorType){
    STContactsProcessorTypeEmails = 0,
    STContactsProcessorTypePhones,

};

@interface STContactsDataProcessor : NSObject

@property (nonatomic, strong) NSArray<STAddressBookContact *> *items;

-(instancetype)initWithType:(STContactsProcessorType) processorType;
-(void)switchSelectionForObjectAtIndex:(NSInteger)index;
-(STAddressBookContact *)objectAtindex:(NSInteger)index;
-(void) commitForViewController:(UIViewController <MFMessageComposeViewControllerDelegate> *)viewController;
@end
