//
//  RIConfiguration.m
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIConfiguration.h"

BOOL const RI_REQUEST_LOGGER = NO;
BOOL const RI_RESPONSE_LOGGER = NO;

NSString *const RI_USERNAME = @"rocket";
NSString *const RI_PASSWORD = @"z7euN7qfRD769BP";
//NSString *const RI_PASSWORD = @"rock4me";

BOOL RI_MOBAPI_HEADERS_ENABLED = NO;
NSString *const RI_MOBAPI_VERSION_HEADER_VERSION_NAME = @"X-ROCKET-MOBAPI-VERSION";
NSString *const RI_MOBAPI_VERSION_HEADER_VERSION_VALUE = @"1.0";
NSString *const RI_MOBAPI_VERSION_HEADER_LANG_NAME = @"X-ROCKET-MOBAPI-LANG";
NSString *const RI_MOBAPI_VERSION_HEADER_LANG_VALUE = @"en";
NSString *const RI_MOBAPI_VERSION_HEADER_TOKEN_NAME = @"X-ROCKET-MOBAPI-TOKEN";
NSString *const RI_MOBAPI_VERSION_HEADER_TOKEN_VALUE = @"a4f04c9433334e4ccd327dfddbfaf08b";

NSString *const RI_HTTP_METHOD_POST = @"POST";
NSString *const RI_HTTP_METHOD_GET = @"GET";
NSString *const RI_HTTP_CONTENT_TYPE_HEADER_NAME = @"Content-Type";
NSString *const RI_HTTP_CONTENT_TYPE_HEADER_FORM_DATA_VALUE = @"application/x-www-form-urlencoded; charset=utf-8";
NSString *const RI_HTTP_CONTENT_TYPE_HEADER_JSON_VALUE = @"application/json; charset=utf-8";
NSString *const RI_HTTP_CONTENT_TYPE_HEADER_PLIST_VALUE = @"application/x-plist; charset=utf-8";

BOOL RI_HTTP_REQUEST_SHOULD_RETRY = YES;
NSInteger RI_HTTP_REQUEST_NUMBER_OF_RETRIES = 3;
NSInteger RI_HTTP_REQUEST_TIMEOUT = 30;

NSString *const RI_HTTP_USER_AGENT_HEADER_NAME = @"User-Agent";
NSString *const RI_HTTP_USER_AGENT_HEADER_IPHONE_VALUE = @"iPhone: Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7";
NSString *const RI_HTTP_USER_AGENT_HEADER_IPAD_VALUE = @"iPad: Mozilla/5.0(iPad; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B314 Safari/531.21.10";

NSString *const RI_HTTP_USER_LANGUAGE_HEADER_NAME = @"User-Language";

NSString *const RI_COUNTRIES_URL_JUMIA = @"http://www.jumia.com/mobapi/availablecountries";
NSString *const RI_COUNTRIES_URL_JUMIA_STAGING = @"http://shareptcmobile.eu.pn/jtmobapi/";
NSString *const RI_COUNTRIES_URL_DARAZ = @"http://www.daraz.com/mobapi/availablecountries";
NSString *const RI_COUNTRIES_URL_DARAZ_STAGING = @"http://shareptcmobile.eu.pn/dtmobapi/";

NSString *const RI_UNIQUE_COUNTRY_URL_SHOP = @"http://www.shop.com.mm/mobapi/";
NSString *const RI_UNIQUE_COUNTRY_URL_SHOP_STAGING = @"http://alice-staging.shop.com.mm/mobapi/";
NSString *const RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_SHOP = @"MMAMZ";
NSString *const RI_UNIQUE_COUNTRY_NAME_SHOP = @"Myanmar";
NSString *const RI_UNIQUE_COUNTRY_ISO_SHOP = @"MM";

NSString *const RI_UNIQUE_COUNTRY_URL_BAMILO = @"http://www.bamilo.com/mobapi/";
NSString *const RI_UNIQUE_COUNTRY_URL_BAMILO_STAGING = @"https://alice-staging.bamilo.com/mobapi/";
NSString *const RI_UNIQUE_COUNTRY_URL_BAMILO_INTEGRATION_MOBILE = @"http://integration-mobile-www.bamilo.com/mobapi/";
NSString *const RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_BAMILO = @"IRAMZ";
NSString *const RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_BAMILO_INTEGRATION_MOBILE = @"M_IRAMZ";
NSString *const RI_UNIQUE_COUNTRY_NAME_BAMILO = @"Iran";
NSString *const RI_UNIQUE_COUNTRY_ISO_BAMILO = @"IR";

NSString *const RI_MOBAPI_PREFIX = @"mobapi/";
NSString *const RI_API_VERSION = @"v2.0/";

NSString *const RI_API_INFO = @"main/md5/";
NSString *const RI_API_IMAGE_RESOLUTIONS = @"main/imageresolutions/";
NSString *const RI_API_GET_TEASERS = @"main/home/";
NSString *const RI_API_COUNTRY_CONFIGURATION = @"main/getconfigurations/";
NSString *const RI_API_GET_STATICBLOCKS = @"main/getstaticblocks/"; //$$$ this one doesn't exist in android, does it have anything to do with the next one?
NSString *const RI_API_PROMOTIONS_URL = @"main/getstatic/key/mobile_promotions/";

NSString *const RI_FORMS_INDEX = @"forms/index/";

NSString *const RI_API_PRODUCT_DETAIL = @"catalog/detail/sku/";
NSString *const RI_API_PROD_VALIDATE = @"catalog/validate/";
NSString *const RI_CATALOG_CATEGORIES = @"catalog/categories/";
NSString *const RI_API_CATALOG = @"search/find/category/";
NSString *const RI_API_SEARCH_SUGGESTIONS = @"search/suggest/";

NSString *const RI_API_ADD_ORDER = @"cart/add/";
//$$$ addbundle & addmultiple requests changed
NSString *const RI_API_ADD_BUNDLE = @"cart/addbundle/";
NSString *const RI_API_ADD_MULTIPLE_ORDER = @"cart/addmultiple/";
NSString *const RI_API_REMOVE_FROM_CART = @"cart/remove/";
NSString *const RI_API_GET_CART_DATA = @"cart/getdata/";
//$$$ CHANGE TO UPDATE PRODUCT
NSString *const RI_API_GET_CART_CHANGE = @"cart/cartchange/";
NSString *const RI_API_ADD_VOUCHER_TO_CART = @"cart/addvoucher/";
NSString *const RI_API_REMOVE_VOUCHER_FROM_CART = @"cart/removevoucher/";

NSString *const RI_API_GET_ORDERS = @"customer/orderlist/";
NSString *const RI_API_TRACK_ORDER = @"customer/trackingorder/ordernr/%@/";
NSString *const RI_API_GET_CUSTOMER = @"customer/getdetails/";
NSString *const RI_API_REGISTER_CUSTOMER = @"customer/create/";
NSString *const RI_API_LOGIN_CUSTOMER = @"customer/login/";
NSString *const RI_API_FACEBOOK_LOGIN_CUSTOMER = @"customer/facebooklogin/";
NSString *const RI_API_LOGOUT_CUSTOMER = @"customer/logout/";
NSString *const RI_API_GET_CUSTOMER_ADDRESS_LIST = @"customer/getaddresslist/";
NSString *const RI_API_GET_CUSTOMER_SELECT_DEFAULT = @"customer/makedefaultaddress/";

NSString *const RI_API_GET_MULTISTEP_ADDRESSES = @"multistep/addresses/";
NSString *const RI_API_GET_SHIPPING_METHODS_FORM = @"multistep/shippingmethod/";
NSString *const RI_API_GET_PAYMENT_METHODS_FORM = @"multistep/paymentmethod/";
NSString *const RI_API_FINISH_CHECKOUT = @"multistep/finish/";

NSString *const RI_GET_CAMPAIGN = @"campaign/get/campaign_slug/%@/";
NSString *const RI_API_BUNDLE = @"catalog/bundle/sku/";

NSString *const RI_API_GET_WISHLIST = @"wishlist/getproducts/";
NSString *const RI_API_ADD_TO_WISHLIST = @"wishlist/addproduct/";
NSString *const RI_API_REMOVE_FOM_WISHLIST = @"wishlist/removeproduct/";

NSString *const RI_API_PRODUCT_OFFERS = @"all_offers/1/";
NSString *const RI_API_SELLER_RATING = @"seller_rating/1/per_page/%d/page/%d/";
NSString *const RI_API_PROD_RATING = @"rating/%d/page/%d/";

NSString *const RI_API_CATALOG_HASH = @"search/find/hash/";
NSString *const RI_API_CATALOG_BRAND = @"search/find/brand/";
NSString *const RI_API_CATALOG_SELLER = @"search/find/seller/";
NSString *const RI_API_CAMPAIGN_PAGE = @"campaign/get/slug/";
NSString *const RI_API_STATIC_PAGE = @"main/getstatic/key/";
NSString *const RI_API_FORMS_GET = @"forms/";
NSString *const RI_API_FORMS_ADDRESS_EDIT = @"addressedit/id/";

