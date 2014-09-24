//
//  CBCFeedViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCFeedViewController.h"
#import "CBCAppDelegate.h"
#import "CBCMedable.h"
#import "CBCHeartRateFeed.h"
#import "CBCHeartRateEvent.h"
#import "CBCImageUtilities.h"
#import "CBCDetailViewController.h"
#import "CBCSocialUtilities.h"
#import "CBCTabBarController.h"


@interface CBCFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *medableLoggedInButton;
@property (weak, nonatomic) IBOutlet UIButton *goToMedableButton;
@property (weak, nonatomic) IBOutlet UIButton *medableInfoButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *resetTrialModeButton;

@property (strong, nonatomic) IBOutlet UISegmentedControl *feedFilterControl;
@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic) BOOL hasPendingEvents;
@property (nonatomic) BOOL hasReachedWillChangeContent;
@property (nonatomic) NSInteger pendingEventCount;

- (IBAction)editList:(id)sender;
- (IBAction)feedFilterChanged:(id)sender;
- (IBAction)medableInfoTouched:(id)sender;
- (IBAction)goToMedableTouched:(id)sender;
- (IBAction)resetTrialModeTouched:(id)sender;

- (NSFetchedResultsController *)fetchedResultsController;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:indexPath;

- (void)medableLoggedInDidChange:(NSNotification *)notification;
- (void)didSwitchFeed:(NSNotification *)notification;

@end

@implementation CBCFeedViewController
//{
//    NSMutableArray *_objectChanges;
//    NSMutableArray *_sectionChanges;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasPendingEvents = NO;
    self.hasReachedWillChangeContent = NO;
    self.pendingEventCount = 0;
    self.resetTrialModeButton.enabled = YES;
    self.resetTrialModeButton.hidden = NO;
    
    self.spinner.hidesWhenStopped = YES;
    [self.spinner stopAnimating];
    
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(medableLoggedInDidChange:) name:kMDNotificationUserDidLogin object:nil];
    [defaultCenter addObserver:self selector:@selector(medableLoggedInDidChange:) name:kMDNotificationUserDidLogout object:nil];
    [defaultCenter addObserver:self selector:@selector(willSwitchFeed:) name:kCBCWillSwitchFeed object:nil];
    [defaultCenter addObserver:self selector:@selector(didSwitchFeed:) name:kCBCDidSwitchFeed object:nil];
    
    [self medableLoggedInDidChange:nil]; // OK - the NSNotification is not used anyway
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)updateEditButton
{
    NSLog(@">> updateEditButton");
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSUInteger numberOfRows = [sectionInfo numberOfObjects];
    
    UITableView *tableView = [self tableView];
    if (![tableView isEditing] || numberOfRows == 0)
    {
        [self.editButton setTitle:@"Edit"];
    }
    else
    {
        [self.editButton setTitle:@"Done"];
    }
    
    [self.editButton setEnabled:(numberOfRows != 0)];
}


#pragma mark - Core Data Fetched Results Controller Delegate

- (NSFetchedResultsController *)fetchedResultsController
{
    CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];

    NSFetchedResultsController * controller = feed.fetchedResultsController;
    controller.delegate = self;

    return controller;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@">> controllerWillChangeContent:\n");
    if (self.hasPendingEvents)
        self.hasReachedWillChangeContent = YES;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"  >> controller:didChangeSection:\n");

    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"  >> controller:didChangeObject:\n");
    
    UITableView *tableView = self.tableView;
    
    if (self.pendingEventCount > 0)
    {
        self.pendingEventCount = self.pendingEventCount - 1;
        NSLog(@"  >> count = %d\n", self.pendingEventCount);
    }
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)setActivityInProgress:(BOOL)inProgress
{
    NSLog(@">> [self setActivityInProgress:%s]\n", inProgress?"YES":"NO");
    if (inProgress)
    {
        self.feedFilterControl.enabled = NO;
        self.tabBarController.tabBar.userInteractionEnabled = NO;
        [self.spinner startAnimating];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCBCActivityDidStart object:nil userInfo:nil];
    }
    else
    {
        BOOL loggedIn = [[CBCMedable singleton] isLoggedIn];
        BOOL inTrialMode = !loggedIn;

        self.feedFilterControl.enabled = !inTrialMode;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        [self.spinner stopAnimating];

        self.hasPendingEvents = NO;
        self.hasReachedWillChangeContent = NO;
        self.pendingEventCount = 0;

        [[NSNotificationCenter defaultCenter] postNotificationName:kCBCActivityDidStop object:nil userInfo:nil];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@">> controllerDidChangeContent:\n");
    [self.tableView endUpdates];
    [self updateEditButton];
    
    if (self.hasPendingEvents && self.pendingEventCount == 0)
    {
        [self setActivityInProgress:NO];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = [[self.fetchedResultsController sections] count];
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger numberOfRows = [sectionInfo numberOfObjects];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedProtoCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CBCHeartRateEvent* event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:event.timeStamp
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    
    UIImage* thumbnail = event.thumbnail;
    if (thumbnail == nil)
    {
        UIImage* image = [UIImage imageWithData:event.photo];
        if (image != nil)
        {
            CGRect cellBounds = cell.bounds;
            if (cellBounds.size.width > 0 && cellBounds.size.height > 0)
            {
                CGSize size;
                size.width = size.height = cellBounds.size.height - 2;
                
                thumbnail = [CBCImageUtilities scaleImage:image toSize:size];
                
                event.thumbnail = thumbnail;
            }
        }
    }
    
    if (thumbnail != nil)
    {
        cell.imageView.image = thumbnail;
    }
}

#pragma mark - Table view editing

- (void)stopEditingTableView
{
    if (self.tabBarController.selectedIndex != 0)
    {
        [self.tableView setEditing:NO animated:NO];
        [self updateEditButton];
    }
}

- (IBAction)editList:(id)sender
{
    UITableView *tableView = [self tableView];

    BOOL wasEditing = [tableView isEditing];
    [tableView setEditing:!wasEditing animated:YES];

    [self updateEditButton];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        CBCHeartRateEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];
        [feed deleteHeartRateEvent:event];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        NSLog(@"We don't support UITableViewCellEditingStyleInsert");
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
    CBCHeartRateEvent * event = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // tell the details view controller which heart rate event to display
    CBCDetailViewController *detailController = [segue destinationViewController];
    detailController.displayedEvent = event;

    NSLog(@"CBCFeedViewController: prepareForSegue: detailController.displayedEvent.heartRate = %@", detailController.displayedEvent.heartRate);
}

#pragma mark - Trial Mode

- (IBAction)resetTrialModeTouched:(id)sender
{
#ifdef DEBUG
    // reset the number of events created to extend the trial period
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"TrialEventCount"];
#endif
}

- (IBAction)medableInfoTouched:(id)sender
{
    [[CBCMedable singleton] showMedableInfoDialog:self];
}

- (IBAction)goToMedableTouched:(id)sender
{
    CBCTabBarController * tabBarController = (CBCTabBarController *)self.tabBarController;
    [tabBarController goToMedableSettings];
}

#pragma mark - Segmented controls

- (IBAction)feedFilterChanged:(id)sender
{
    BOOL loggedIn = [[CBCMedable singleton] isLoggedIn];
    
    NSLog(@">> feedFilterChanged loggedIn=%s selectedSegmentIndex=%d", loggedIn?"YES":"NO", self.feedFilterControl.selectedSegmentIndex);

    if (!loggedIn)
        [[CBCFeedManager singleton] switchToFeed:CBCFeedLocal];
    else
        [[CBCFeedManager singleton] switchToFeed:self.feedFilterControl.selectedSegmentIndex];
}

- (void)medableLoggedInDidChange:(NSNotification *)notification
{
    BOOL loggedIn = [[CBCMedable singleton] isLoggedIn];
    BOOL inTrialMode = !loggedIn;

    NSLog(@">> medableLoggedInDidChange: loggedIn=%s inTrialMode=%s", loggedIn?"YES":"NO", inTrialMode?"YES":"NO");
    
    self.medableLoggedInButton.enabled = loggedIn;
    
    if (inTrialMode || self.feedFilterControl.selectedSegmentIndex < 0)
    {
        self.feedFilterControl.selectedSegmentIndex = CBCFeedPrivate;
    }
    
    self.feedFilterControl.enabled = !inTrialMode;
    
    // when in trial mode, the medableInfoButton brings up info on medable
    // when in full medable mode, the goToMedableButton takes the user directly
    // to the Medable settings page
    self.goToMedableButton.userInteractionEnabled = !inTrialMode;
    self.goToMedableButton.hidden = inTrialMode;
    
    self.medableInfoButton.userInteractionEnabled = inTrialMode;
    self.medableInfoButton.hidden = !inTrialMode;
    
    if (!loggedIn)
    {
        [[CBCFeedManager singleton] switchToFeed:CBCFeedLocal];
    }
    else
    {
        /*
        CBCFeed * previousFeed = [[CBCFeedManager singleton] currentFeed];
        */
        
        [[CBCFeedManager singleton] switchToFeed:self.feedFilterControl.selectedSegmentIndex];

        /*
        CBCFeed * currentFeed = [[CBCFeedManager singleton] currentFeed];
        
        if (previousFeed != nil && previousFeed.type == CBCFeedLocal && currentFeed != nil)
        {
            // if there are any saved events in the local Core Data store, automatically post them
            // to the user's Medable feed
            
            NSArray * localEvents = [previousFeed fetchAllHeartRateEvents];
            
            if (localEvents != nil && localEvents.count != 0)
            {
                //int __block count = localEvents.count;
    
                for (CBCHeartRateEvent * localEvent in localEvents)
                {
                    CBCHeartRateEvent * event = [currentFeed createHeartRateEvent];
                    
                    event.eventDescription = [localEvent.eventDescription copy];
                    event.heartRate = [localEvent.heartRate copy];
                    event.photo = [localEvent.photo copy];
                    event.timeStamp = [localEvent.timeStamp copy];
                    event.backgroundImage = [localEvent.backgroundImage copy];
                    event.overlayImage = [localEvent.overlayImage copy];
                    event.postedToFacebook = [localEvent.postedToFacebook copy];
                    event.postedToTwitter = [localEvent.postedToTwitter copy];
                    event.postedToMedable = NO;
                    event.thumbnail = nil;
                    
                    [currentFeed saveHeartRateEvent:event];
                }
            }
        }
        */
    }
}

- (void)willSwitchFeed:(NSNotification *)notification
{
    NSNumber * newFeedTypeNum = [notification.userInfo objectForKey:@"NewFeedType"];
    CBCFeedType newFeedType = (CBCFeedType)newFeedTypeNum.intValue;
    
    NSLog(@">> willSwitchFeed to %@", [CBCFeed typeAsString:newFeedType]);
    
    [self setActivityInProgress:YES];
}

- (void)didSwitchFeed:(NSNotification *)notification
{
    NSInteger count = [[notification.userInfo objectForKey:@"Count"] intValue];

    NSNumber * newFeedTypeNum = [notification.userInfo objectForKey:@"NewFeedType"];
    CBCFeedType newFeedType = (CBCFeedType)newFeedTypeNum.intValue;
    
    NSLog(@">> didSwitchFeed to %@ count = %d", [CBCFeed typeAsString:newFeedType], count);

    self.fetchedResultsController.delegate = self;
    [self.tableView reloadData];
    
    self.pendingEventCount = count;
    self.hasPendingEvents = (count > 0);
    self.hasReachedWillChangeContent = NO;

    if (!self.hasPendingEvents)
        [self setActivityInProgress:NO];
    else
    {
        NSLog(@">> starting timer...");
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:NO];
    }
}

- (void)timerFireMethod:(NSTimer *)timer
{
    NSLog(@">> timer fired");
    if (self.hasPendingEvents && !self.hasReachedWillChangeContent)
    {
        NSLog(@">> timer had unprocessed pending events!");
        [self setActivityInProgress:NO];
    }
    self.timer = nil;
}

#pragma mark - Medable feed

    
@end
