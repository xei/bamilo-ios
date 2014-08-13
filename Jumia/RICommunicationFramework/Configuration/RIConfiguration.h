//
//  RIConfiguration.h
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const RI_USERNAME;
FOUNDATION_EXPORT NSString *const RI_PASSWORD;

FOUNDATION_EXPORT BOOL RI_MOBAPI_HEADERS_ENABLED;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_VERSION_NAME;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_VERSION_VALUE;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_LANG_NAME;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_LANG_VALUE;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_TOKEN_NAME;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_TOKEN_VALUE;

FOUNDATION_EXPORT NSString *const RI_HTTP_METHOD_POST;
FOUNDATION_EXPORT NSString *const RI_HTTP_METHOD_GET;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_NAME;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_FORM_DATA_VALUE;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_JSON_VALUE;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_PLIST_VALUE;

FOUNDATION_EXPORT BOOL RI_HTTP_REQUEST_SHOULD_RETRY;
FOUNDATION_EXPORT NSInteger RI_HTTP_REQUEST_NUMBER_OF_RETRIES;
FOUNDATION_EXPORT NSInteger RI_HTTP_REQUEST_TIMEOUT;

FOUNDATION_EXPORT NSString *const RI_COUNTRIES_URL;
FOUNDATION_EXPORT NSString *const RI_BASE_URL;
FOUNDATION_EXPORT NSString *const RI_API_VERSION;
FOUNDATION_EXPORT NSString *const RI_CATALOG_CATEGORIES;
FOUNDATION_EXPORT NSString *const RI_FORMS_INDEX;
FOUNDATION_EXPORT NSString *const RI_API_INFO;
FOUNDATION_EXPORT NSString *const RI_API_IMAGE_RESOLUTIONS;
FOUNDATION_EXPORT NSString *const RI_API_GET_TEASERS;
FOUNDATION_EXPORT NSString *const RI_API_GET_STATICBLOCKS;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_REGISTER_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_LOGIN_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_FACEBOOK_LOGIN_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_LOGOUT_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_RATING_OPTIONS;
FOUNDATION_EXPORT NSString *const RI_API_SEARCH_SUGGESTIONS;
FOUNDATION_EXPORT NSString *const RI_API_COUNTRY_CONFIGURATION;
FOUNDATION_EXPORT NSString *const RI_API_ADD_ORDER;
FOUNDATION_EXPORT NSString *const RI_API_GET_CART_DATA;
FOUNDATION_EXPORT NSString *const RI_API_GET_CART_CHANGE;
FOUNDATION_EXPORT NSString *const RI_API_REMOVE_FROM_CART;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER_BILLING_ADDRESS;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER_ADDRESS_LIST;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER_BILLING_ADDRESS;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER_ADDRESS_LIST;
FOUNDATION_EXPORT NSString *const RI_API_GET_BILLING_ADDRESS_FORM;
FOUNDATION_EXPORT NSString *const RI_API_GET_SHIPPING_ADDRESS_FORM;
FOUNDATION_EXPORT NSString *const RI_API_GET_SHIPPING_METHODS_FORM;
FOUNDATION_EXPORT NSString *const RI_API_GET_PAYMENT_METHODS_FORM;
FOUNDATION_EXPORT NSString *const RI_API_FINISH_CHECKOUT;
