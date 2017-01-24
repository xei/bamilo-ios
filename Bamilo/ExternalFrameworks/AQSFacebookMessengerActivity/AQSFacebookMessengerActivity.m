//
//  AQSFacebookMessengerActivity.m
//  AQSFacebookMessengerActivity
//
//  Created by kaiinui on 2014/11/11.
//  Copyright (c) 2014年 Aquamarine. All rights reserved.
//

#import "AQSFacebookMessengerActivity.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface AQSFacebookMessengerActivity ()

@property (nonatomic, strong) NSArray *activityItems;

@end

@implementation AQSFacebookMessengerActivity

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    [super prepareWithActivityItems:activityItems];
    
    self.activityItems = activityItems;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"org.openaquamarine.facebookmessenger";
}

- (NSString *)activityTitle {
    return @"Facebook Messenger";
}

- (UIImage *)activityImage {
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 8) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"color_%@", NSStringFromClass([self class])]];
    } else {
        return [UIImage imageNamed:NSStringFromClass([self class])];
    }
}

- (void)performActivity {
    UIImage *image = [self nilOrFirstImageFromArray:_activityItems];
    NSURL *URL = [self nilOrFirstURLFromArray:_activityItems];
    FBSDKSharePhotoContent *photoParams = [self nilOrFirstPhotoParamsFromArray:_activityItems];
    FBSDKShareLinkContent *linkParams = [self nilOrFirstLinkShareParamsFromArray:_activityItems];
    
    if (linkParams) {
        [FBSDKMessageDialog showWithContent:linkParams delegate:nil];
    } else if (photoParams) {
        [FBSDKMessageDialog showWithContent:photoParams delegate:nil];
    } else if (image) {
        NSLog(@"NOT SUPPORTED YET!");
//        [self performActivityWithImageArray:_activityItems];
    } else if (URL) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = URL;
        [FBSDKMessageDialog showWithContent:content delegate:nil];
    }
}

# pragma mark - Helpers (Array)

- (NSURL *)nilOrFirstURLFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[NSURL class]]) {
            return item;
        }
    }
    return nil;
}

- (FBSDKShareLinkContent *)nilOrFirstLinkShareParamsFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[FBSDKShareLinkContent class]]) {
            return item;
        }
    }
    return nil;
}

- (FBSDKSharePhotoContent *)nilOrFirstPhotoParamsFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[FBSDKSharePhotoContent class]]) {
            return item;
        }
    }
    return nil;
}

- (UIImage *)nilOrFirstImageFromArray:(NSArray *)array {
    for (id item in array) {
        if ([item isKindOfClass:[UIImage class]]) {
            return item;
        }
    }
    return nil;
}

- (NSArray *)emptyOrImageArrayFromArray:(NSArray *)array {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (id item in array) {
        if ([item isKindOfClass:[UIImage class]]) {
            [mutableArray addObject:item];
        }
    }
    return mutableArray;
}

@end
