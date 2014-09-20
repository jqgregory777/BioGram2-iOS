//
//  CBCAppDelegate.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/11/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CBCHeartRateEvent.h"
#import "AliveHMViewController.h"

@class CBCDetailViewController;

@interface CBCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CBCAppDelegate*)appDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

#pragma mark - Heart Rate Event Creation

// The CBCAppDelegate manages creation of a new CBCHeartRateEvent.
// Once created, its attributes are populated (via a sequence of UI pages).
// If the user backs out, the pending event is canceled and destroyed.
// If the user progresses to the end of the page sequence and hits Save,
// the event is committed to the persistent store.

@property (strong, nonatomic) CBCHeartRateEvent *pendingHeartRateEvent;
@property UIImage * pendingRawImage;

- (CBCHeartRateEvent *)createPendingHeartRateEvent;
- (void)cancelPendingHeartRateEvent;
- (BOOL)savePendingHeartRateEvent;
- (BOOL)updateHeartRateEvent:(CBCHeartRateEvent *)heartRateEvent;


#pragma mark - Utilities

+ (void)showMessage:(NSString *)message withTitle:(NSString *)title;

@end
