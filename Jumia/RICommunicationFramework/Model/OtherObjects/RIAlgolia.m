//
//  RIAlgolia.m
//  Jumia
//
//  Created by Jose Mota on 12/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "RIAlgolia.h"

@interface RIAlgolia ()
{
    NSUInteger _searchId;
    NSString *_langCode;
}

@property (nonatomic) ASAPIClient *apiClient;
@property (nonatomic) ASQuery *productsQuery;
@property (nonatomic) ASQuery *shopInShopQuery;
@property (nonatomic) ASQuery *categoriesQuery;
@property (nonatomic) NSArray *queries;
@property (nonatomic) ASRemoteIndex *categoriesIndex;

@property (nonatomic) NSString *productsIndexName;
@property (nonatomic) NSString *shopInShopIndexName;
@property (nonatomic) NSString *categoriesIndexName;

@end

@implementation RIAlgolia

+ (instancetype)sharedInstance {
    static id defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [self new];
        [defaultInstance setDefaults];
    });
    return defaultInstance;
}

- (void)setDefaults
{
    
    self.apiClient = [ASAPIClient apiClientWithApplicationID:[RICountryConfiguration getCurrentConfiguration].algoliaAppId apiKey:[RICountryConfiguration getCurrentConfiguration].algoliaApiKey];
    
    self.productsQuery = [[ASQuery alloc] init];
    self.productsQuery.hitsPerPage =3;
    self.productsQuery.attributesToRetrieve = @[@"sku", @"localizable_attributes"];
    self.productsQuery.attributesToHighlight = @[@"facet_category"];
    self.productsQuery.facets = @[@"facet_category"];
    self.productsQuery.maxValuesPerFacet = 4;
    
    self.shopInShopQuery = [[ASQuery alloc] init];
    self.shopInShopQuery.hitsPerPage =1;
    
    self.productsIndexName = [NSString stringWithFormat:@"%@_products_popular", [RICountryConfiguration getCurrentConfiguration].algoliaNamespacePrefix];
    self.shopInShopIndexName = [NSString stringWithFormat:@"%@_shopinshop", [RICountryConfiguration getCurrentConfiguration].algoliaNamespacePrefix];
    self.categoriesIndexName = [NSString stringWithFormat:@"%@_categories", [RICountryConfiguration getCurrentConfiguration].algoliaNamespacePrefix];
    self.queries = @[@{@"indexName": self.productsIndexName, @"query": self.productsQuery},
                          @{@"indexName": self.shopInShopIndexName, @"query": self.shopInShopQuery}
                          ];
    
    _langCode = [[NSUserDefaults standardUserDefaults] stringForKey:kLanguageCodeKey];
    
    self.categoriesQuery = [[ASQuery alloc] init];
    
    self.categoriesIndex = [self.apiClient getIndex:self.categoriesIndexName];
}

- (void)getSearchResultsForQuery:(NSString *)textToQuery
              onFirstStepSuccess:(void(^)(NSArray *productsResults, NSArray *shopInShopResults))firstStepSuccess
             onSecondStepSuccess:(void(^)(NSArray *categoryResults))secondStepSuccess
                         onError:(void(^)(NSString *error))error
{
    for (NSDictionary *queryDictionary in self.queries) {
        ASQuery *query = [queryDictionary objectForKey:@"query"];
        query.fullTextQuery = textToQuery;
    }
    __block NSInteger index = _searchId;
    [self.apiClient multipleQueries:self.queries
                            success:^(ASAPIClient *client, NSArray *queries, NSDictionary *multipleResults) {
                                
                                if (index < _searchId) {
                                    return;
                                }
                                NSDictionary *results = [multipleResults objectForKey:@"results"];
                                if (multipleResults) {
                                    NSArray *facetCategoryArray = [NSMutableArray new];
                                    
                                    NSMutableArray *tmpProducts = [NSMutableArray array];
                                    NSMutableArray *tmpShopInShop = [NSMutableArray array];
                                    for (NSDictionary *result in results) {
                                        NSArray *hits = result[@"hits"];
                                        if ([[result objectForKey:@"index"] isEqualToString:self.productsIndexName]) {
                                            
                                            facetCategoryArray = [[[[result objectForKey:@"facets"] objectForKey:@"facet_category"] allKeys] copy];
                                            
                                            if (facetCategoryArray.count > 0) {
                                                
                                                NSMutableArray *facets = [NSMutableArray new];
                                                for (NSNumber *nb in facetCategoryArray) {
                                                    [facets addObject:[NSString stringWithFormat:@"id_catalog_category:%@", nb]];
                                                }
                                                
                                                self.categoriesQuery.facetFiltersRaw = [NSString stringWithFormat:@"(%@)", [facets componentsJoinedByString:@","]];
                                                __block NSInteger indexCat = _searchId;
                                                [self.categoriesIndex search:self.categoriesQuery success:^(ASRemoteIndex *index, ASQuery *query, NSDictionary *categoriesResult) {
                                                    if (indexCat < _searchId) {
                                                        return;
                                                    }
                                                    NSArray *hits = categoriesResult[@"hits"];
                                                    NSMutableArray *tmpCategories = [NSMutableArray array];
                                                    for (NSDictionary *hit in hits) {
                                                        
                                                        NSString *label = [[[hit objectForKey:@"localizable_attributes"] objectForKey:_langCode] objectForKey:@"name"];
                                                        NSString *value = [[[hit objectForKey:@"localizable_attributes"] objectForKey:_langCode] objectForKey:@"url_key"];
                                                        NSDictionary *categoriesDict = @{@"item":label, @"value":value};
                                                        [tmpCategories addObject:categoriesDict];
                                                    }
                                                    
                                                    secondStepSuccess(tmpCategories);
                                                } failure:^(ASRemoteIndex *index, ASQuery *query, NSString *errorMessage) {
                                                    error(errorMessage);
                                                }];
                                            }
                                        }
                                        for (int i = 0; i < [hits count]; ++i) {
                                            if ([[result objectForKey:@"index"] isEqualToString:self.shopInShopIndexName]) {
                                                NSString *label = [hits[i] objectForKey:@"domain"];
                                                NSString *value = VALID_NOTEMPTY_VALUE([hits[i] objectForKey:@"pointer"], NSString);
                                                if (!value) {
                                                    value = label;
                                                }
                                                NSDictionary *shopInShopDict = @{@"item":label, @"value":value};
                                                [tmpShopInShop addObject:shopInShopDict];
                                            }else if ([[result objectForKey:@"index"] isEqualToString:self.productsIndexName]) {
                                                NSString *label = [[[hits[i] objectForKey:@"localizable_attributes"] objectForKey:_langCode] objectForKey:@"name"];
                                                NSString *value = [hits[i] objectForKey:@"sku"];
                                                NSDictionary *productDict = @{@"item":label, @"value":value};
                                                [tmpProducts addObject:productDict];
                                            }
                                        }
                                    }
                                    firstStepSuccess(tmpProducts, tmpShopInShop);
                                }
                                
                            } failure:^(ASAPIClient *client, NSArray *queries, NSString *errorMessage) {
                                error(errorMessage);
                            }];

}

@end
