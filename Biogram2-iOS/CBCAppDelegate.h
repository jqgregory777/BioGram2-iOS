//
//  CBCAppDelegate.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCHeartRateEvent.h"
#import "CBCMedableAccount.h"

@interface CBCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

#pragma mark - Heart Rate Event Creation

@property (strong, nonatomic) CBCHeartRateEvent *pendingHeartRateEvent;
@property UIImage * pendingRawImage;

- (CBCHeartRateEvent *)beginCreatingHeartRateEvent;
- (void)cancelPendingHeartRateEvent;
- (BOOL)savePendingHeartRateEvent;

#pragma mark - Medable

@property CBCMedableAccount *medableAccount;

- (void)createMedableAccount:(CBCMedableAccount*)account;
- (void)deleteMedableAccount;

@end
