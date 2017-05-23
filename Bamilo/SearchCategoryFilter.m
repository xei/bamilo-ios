////
////  SearchCategoryFilter.m
////  Bamilo
////
////  Created by Ali Saeedifar on 3/6/17.
////  Copyright © 2017 Rocket Internet. All rights reserved.
////
//
//#import "SearchCategoryFilter.h"
//
//@implementation SearchCategoryFilter
//- (BOOL)mergeFromDictionary:(NSDictionary *)dict useKeyMapping:(BOOL)useKeyMapping error:(NSError *__autoreleasing *)error {
//    BOOL result = [super mergeFromDictionary:dict useKeyMapping:useKeyMapping error:error];
//    
//    self.multi = NO;
//    self.name = STRING_SUBCATEGORIES; //[dict objectForKey:@"label"];
//    self.uid = [dict objectForKey:@"url_key"];
//    
//    if ([[dict objectForKey:@"children"] isKindOfClass:[NSArray class]]) {
//        NSMutableArray *filterOptions = [NSMutableArray new];
//        [((NSArray *)[dict objectForKey:@"children"]) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            SearchFilterItemOption *filterOption = [SearchFilterItemOption new];
//            filterOption.name = [obj objectForKey:@"label"];
//            filterOption.value = [obj objectForKey:@"url_key"];
//            [filterOptions addObject:filterOption];
//        }];
//        self.options = [filterOptions copy];
//    }
//    return result;
//}
//@end
