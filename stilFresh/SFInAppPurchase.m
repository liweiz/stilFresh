//
//  SFInAppPurchase.m
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-22.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import "SFInAppPurchase.h"


#import "RMStoreTransactionReceiptVerificator.h"
#import "RMStoreAppReceiptVerificator.h"
#import "RMStoreKeychainPersistence.h"

@interface SFInAppPurchase ()

@property (nonatomic, strong) RMStoreAppReceiptVerificator *receiptVerificator;
@property (nonatomic, strong) RMStoreKeychainPersistence *transactionPersistor;
@property (nonatomic, strong) NSArray *productIdentifiers;
@property (nonatomic, strong) NSString *localPriceString;

@end

@implementation SFInAppPurchase

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *alertTitle = @"Please confirm your purchase";
        NSString *alertMsg = [@"Do you want to buy the option to unlock unlimited items for " stringByAppendingString:self.localPriceString];
    }
    return self;
}

#pragma mark - To Buy
- (void)toBuy {
    if ([RMStore canMakePayments]) {
        [self getProductInfo];
    } else {
        // Show warning
    }
}

- (void)getProductInfo {
    [[RMStore defaultStore] requestProducts:[NSSet setWithObject:@"stilFresh2014"] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        if ([products count] == 1) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:[(SKProduct *)products[0] priceLocale]];
            self.localPriceString = nil;
            self.localPriceString = [numberFormatter stringFromNumber:[(SKProduct *)products[0] price]];
        } else {
            // Show warning
        }
    } failure:^(NSError *error) {
        // Show warning
    }];
}

#pragma mark - To Pay
- (void)toPay:(NSString *)productId {
    [[RMStore defaultStore] addPayment:productId success:^(SKPaymentTransaction *transaction) {
        // Unlock feature
    }failure:^(SKPaymentTransaction *transaction, NSError *error) {
        // Show warning
    }];
}



- (void)configureStore {
    [[RMStore defaultStore] addStoreObserver:self];
    if (!self.receiptVerificator) {
        self.receiptVerificator = [[RMStoreAppReceiptVerificator alloc] init];
    }
    [RMStore defaultStore].receiptVerificator = self.receiptVerificator;
    if (!self.transactionPersistor) {
        self.transactionPersistor = [[RMStoreKeychainPersistence alloc] init];
    }
    [RMStore defaultStore].transactionPersistor = self.transactionPersistor;
    self.productIdentifiers = [[self.transactionPersistor purchasedProductIdentifiers] allObjects];
}

#pragma mark - Actions

- (void)restoreAction
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        // Refresh view
    } failure:^(NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Restore Transactions Failed", @"")
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)trashAction
{
    [self.transactionPersistor removeTransactions];
    self.productIdentifiers = [[self.transactionPersistor purchasedProductIdentifiers] allObjects];
    // Refresh view
}

#pragma mark - RMStoreObserver

- (void)storeProductsRequestFinished:(NSNotification*)notification
{
    // Reload view
}

- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
    self.productIdentifiers = [[self.transactionPersistor purchasedProductIdentifiers] allObjects];
    // Reload view
}

- (void)dealloc
{
    [[RMStore defaultStore] removeStoreObserver:self];
}

@end
