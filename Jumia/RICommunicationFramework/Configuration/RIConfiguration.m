//
//  RIConfiguration.m
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIConfiguration.h"

NSString *const RI_USERNAME = @"rocket";
NSString *const RI_PASSWORD = @"rock4me";

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

NSString *const RI_COUNTRIES_URL = @"https://www.jumia.com/mobapi/ventures.json";
NSString *const RI_BASE_URL = @"https://alice-staging.jumia.com.eg/mobapi/";
NSString *const RI_API_VERSION = @"v1.4/";
NSString *const RI_CATALOG_CATEGORIES = @"catalog/categories/";
NSString *const RI_FORMS_INDEX = @"forms/index/";
NSString *const RI_API_INFO = @"main/md5/";
NSString *const RI_API_IMAGE_RESOLUTIONS = @"main/imageresolutions/";
NSString *const RI_API_GET_TEASERS = @"main/getteasers/";
NSString *const RI_API_GET_STATICBLOCKS = @"main/getstaticblocks/";
NSString *const RI_API_GET_CUSTOMER = @"customer/getdetails?setDevice=mobileApi";
NSString *const RI_API_LOGIN_CUSTOMER = @"customer/login/";
NSString *const RI_API_FACEBOOK_LOGIN_CUSTOMER = @"customer/facebooklogin?setDevice=mobileApi&facebook=true";
NSString *const RI_API_LOGOUT_CUSTOMER = @"customer/logout/";
NSString *const RI_API_RATING_OPTIONS = @"rating/options/";
NSString *const RI_API_SEARCH_SUGGESTIONS = @"search/suggest/";
NSString *const RI_API_COUNTRY_CONFIGURATION = @"main/getcountryconfs/";
NSString *const RI_API_ADD_ORDER = @"order/add?setDevice=mobileApi";
NSString *const RI_API_GET_CART_DATA = @"order/cartdata?setDevice=mobileApi";
NSString *const RI_API_GET_CART_CHANGE = @"order/cartchange/";
NSString *const RI_API_REMOVE_FROM_CART = @"order/remove?setDevice=mobileApi";
NSString *const RI_API_GET_CUSTOMER_BILLING_ADDRESS = @"/customer/billingaddress/";
NSString *const RI_API_GET_CUSTOMER_ADDRESS_LIST = @"/customer/address/list/";
NSString *const RI_API_GET_BILLING_ADDRESS_FORM = @"multistep/billing/";
NSString *const RI_API_GET_SHIPPING_ADDRESS_FORM = @"multistep/shipping/";
NSString *const RI_API_GET_SHIPPING_METHODS_FORM = @"multistep/shippingmethod/";
NSString *const RI_API_GET_PAYMENT_METHODS_FORM = @"multistep/paymentmethod/";
NSString *const RI_API_FINISH_CHECKOUT = @"multistep/finish/";