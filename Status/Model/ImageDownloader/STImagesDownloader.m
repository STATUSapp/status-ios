//
//  STImagesDownloader.m
//  Status
//
//  Created by Andrus Cosmin on 08/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STImagesDownloader.h"
#import "STPost.h"

@interface STImagesDownloader ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) STImageDownloaderType type;

@end

@implementation STImagesDownloader

-(instancetype)initWithType:(STImageDownloaderType)type{
    self = [super init];
    if (self) {
        self.type = type;
        self.items = [NSMutableArray new];
    }
    return self;
}

- (void)addObjects:(NSArray *)objects{
    [_items addObjectsFromArray:objects];
}
- (void)arrangeObjectUsingPredicate:(NSPredicate *)predicate{
    
}

@end

@interface STDownloadItem ()

@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSString *url;

@end

@implementation STDownloadItem

+(STDownloadItem *)downloadItemFromPost:(STPost *)post
                                andType:(NSInteger)type{
    STDownloadItem *di = [STDownloadItem new];
    di.type = @(type);
    di.url = post.
}

@end
