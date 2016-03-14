//
//  STImagesDownloader.h
//  Status
//
//  Created by Andrus Cosmin on 08/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, STImageDownloaderType) {
    STImageDownloaderTypePosts = 0
};


@interface STImagesDownloader : NSObject

- (void)addObjects:(NSArray *)objects;
- (void)arrangeObjectUsingPredicate:(NSPredicate *)predicate;

@end

@interface STDownloadItem : NSObject

@end
