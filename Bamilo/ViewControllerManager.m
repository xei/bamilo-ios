//
//  ViewControllerManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ViewControllerManager.h"

@implementation ViewControllerManager {
@private
    NSMutableDictionary *_storyboardCache;
    NSMutableDictionary *_viewControllerCache;
}

static ViewControllerManager *instance;

- (instancetype)init {
    if (self = [super init]) {
        _storyboardCache = [NSMutableDictionary new];
        _viewControllerCache = [NSMutableDictionary new];
    }
    return self;
}

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ViewControllerManager alloc] init];
    });
    
    return instance;
}

- (UIViewController *) loadViewController:(NSString *)nibName {
    return [self loadViewController:nibName resetCache:YES];
}

- (UIViewController *) loadViewController:(NSString *)nibName resetCache:(BOOL)resetCache {
    return [self loadViewController:@"Main" nibName:nibName resetCache:resetCache];
}

- (UIViewController *) loadViewController:(NSString *)storyboard nibName:(NSString *)nibName resetCache:(BOOL)resetCache {
    UIStoryboard *destStoryboard = [_storyboardCache objectForKey:storyboard];
    
    if(destStoryboard == nil) {
        destStoryboard = [UIStoryboard storyboardWithName:storyboard bundle:nil];
        [_storyboardCache setObject:destStoryboard forKey:storyboard];
    }
    
    NSString *viewControllerFullKey = [self getFullKeyFor:storyboard nibName:nibName];
    
    if(resetCache) {
        [_viewControllerCache removeObjectForKey:viewControllerFullKey];
    }
    
    UIViewController *destViewController = [_viewControllerCache objectForKey:viewControllerFullKey];
    
    if(destViewController == nil) {
        destViewController = [destStoryboard instantiateViewControllerWithIdentifier:nibName];
        [_viewControllerCache setObject:destViewController forKey:viewControllerFullKey];
    }
    
    return destViewController;
}

#pragma mark - Private Methods
-(NSString *)getFullKeyFor:(NSString *)storyboard nibName:(NSString *)nibName {
    return [NSString stringWithFormat:@"%@-%@", storyboard, nibName];
}

@end
