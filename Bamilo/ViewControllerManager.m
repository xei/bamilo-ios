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
    NSMutableDictionary *_nibCache;
}

//EXTENSION
+(JARootViewController *)rootViewController {
    return (JARootViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"Main" nibName:@"JARootViewController" resetCache:NO];
}

+(JACenterNavigationController *)centerViewController {
    return (JACenterNavigationController *)[[ViewControllerManager sharedInstance] loadViewController:@"Main" nibName:@"JACenterNavigationController" resetCache:NO];
}

+(id)topViewController {
    return [[ViewControllerManager centerViewController] topViewController];
}
//EXTENSION

static ViewControllerManager *instance;

- (instancetype)init {
    if (self = [super init]) {
        _storyboardCache = [NSMutableDictionary new];
        _viewControllerCache = [NSMutableDictionary new];
        _nibCache = [NSMutableDictionary new];
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

-(UIViewController *)loadNib:(NSString *)nibName resetCache:(BOOL)resetCache {
    UIViewController *destViewController = [_nibCache objectForKey:nibName];
    
    if(resetCache || destViewController == nil) {
        destViewController = [(UIViewController *)[NSClassFromString(nibName) alloc] initWithNibName:nibName bundle:nil];
        [_nibCache removeObjectForKey:nibName];
        [_nibCache setObject:destViewController forKey:nibName];
    }
    
    return destViewController;
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


- (void)clearCache {
    [_viewControllerCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[JARootViewController class]] && ![obj isKindOfClass:[JACenterNavigationController class]]) {
            [_viewControllerCache removeObjectForKey:key];
        }
    }];
}

@end
