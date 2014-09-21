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


@interface CBCFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *medableLoggedInButton;
@property (weak, nonatomic) IBOutlet UIButton *goToMedableButton;
@property (weak, nonatomic) IBOutlet UIButton *medableInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *resetTrialModeButton;

@property (strong, nonatomic) IBOutlet UISegmentedControl *feedFilterControl;

@property (nonatomic, strong) NSMutableArray* data;

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

#ifdef DEBUG
    self.resetTrialModeButton.enabled = YES;
    self.resetTrialModeButton.hidden = NO;
    self.resetTrialModeButton.userInteractionEnabled = YES;
#else
    self.resetTrialModeButton.enabled = NO;
    self.resetTrialModeButton.hidden = YES;
    self.resetTrialModeButton.userInteractionEnabled = NO;
#endif
    
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(medableLoggedInDidChange:) name:kMDNotificationUserDidLogin object:nil];
    [defaultCenter addObserver:self selector:@selector(medableLoggedInDidChange:) name:kMDNotificationUserDidLogout object:nil];
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

- (NSMutableArray*)data
{
    if (!_data)
    {
        _data = [NSMutableArray array];
    }
    
    return _data;
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@">> controllerDidChangeContent:\n");
    [self.tableView endUpdates];
    [self updateEditButton];
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
            CGSize size;
            size.width = size.height = cellBounds.size.height - 2;
            
            thumbnail = [CBCImageUtilities scaleImage:image toSize:size];
            
            event.thumbnail = thumbnail;
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
        // Delete from CoreData

        CBCFeed * feed = [[CBCFeedManager singleton] currentFeed];

        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSManagedObjectContext *context = [feed managedObjectContext];
        CBCHeartRateEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [context deleteObject:event];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
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
    NSLog(@"medableInfoTouched:");

    NSString * message = [NSString stringWithCString:
        "Protect your heart rate data with Medable, the world’s first HIPAA-compliant medical data service. "
        "Create an account and log in to unlock all of the features of Biogram."
        encoding:NSUTF8StringEncoding];
    
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:@"Medable"
                          message:NSLocalizedString(message, nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:NSLocalizedString(@"www.medable.com", nil), nil];
    [alert show];
}

- (IBAction)goToMedableTouched:(id)sender
{
    NSLog(@"goToMedableTouched:");
    
    // go to settings tab
    self.tabBarController.selectedIndex = 2;
    
    // go to medable settings page
    UINavigationController * settingsNavControl = self.tabBarController.viewControllers[2];
    NSArray * presentedSettingsControllers = settingsNavControl.viewControllers;
    
    BOOL foundMedableController = NO;
    int count = presentedSettingsControllers.count;
    for (int i = 0; i < count; i++)
    {
        UIViewController * controller = [presentedSettingsControllers objectAtIndex:i];
        if ([controller.restorationIdentifier isEqualToString:@"medableMainTableViewController"])
        {
            foundMedableController = YES;
            break;
        }
    }
    
    if (!foundMedableController)
    {
        UIViewController * settingsViewControl = settingsNavControl.childViewControllers[0];
        [settingsViewControl performSegueWithIdentifier:@"goToMedableSettingsSegue" sender:self];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self goToMedableTouched:self];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.medable.com/about.html"]];
    }
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
        self.feedFilterControl.selectedSegmentIndex = CBCFeedPrivate;
    [self.feedFilterControl setEnabled:!inTrialMode forSegmentAtIndex:CBCFeedPrivate];
    [self.feedFilterControl setEnabled:!inTrialMode forSegmentAtIndex:CBCFeedPublic];
    [self.feedFilterControl setEnabled:NO/*!inTrialMode*/ forSegmentAtIndex:CBCFeedCollective]; // FIXME -- this crashes right now
    
    // when in trial mode, the medableInfoButton brings up info on medable
    // when in full medable mode, the goToMedableButton takes the user directly
    // to the Medable settings page
    self.goToMedableButton.userInteractionEnabled = !inTrialMode;
    self.goToMedableButton.hidden = inTrialMode;
    
    self.medableInfoButton.userInteractionEnabled = inTrialMode;
    self.medableInfoButton.hidden = !inTrialMode;
    
#ifdef DEBUG
    self.resetTrialModeButton.enabled = ([[NSUserDefaults standardUserDefaults] integerForKey:@"TrialEventCount"] != 0);
#endif

    if (!loggedIn)
        [[CBCFeedManager singleton] switchToFeed:CBCFeedLocal];
    else
        [[CBCFeedManager singleton] switchToFeed:self.feedFilterControl.selectedSegmentIndex];
}

- (void)didSwitchFeed:(NSNotification *)notification
{
    NSLog(@">> didSwitchFeed");
    self.fetchedResultsController.delegate = self;
    [self.tableView reloadData];
}

#pragma mark - Medable feed

    
@end
