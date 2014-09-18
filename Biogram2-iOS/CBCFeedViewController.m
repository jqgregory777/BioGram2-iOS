//
//  CBCFeedViewController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCFeedViewController.h"
#import "CBCAppDelegate.h"
#import "CBCHeartRateEvent.h"
#import "CBCImageUtilities.h"
#import "CBCDetailViewController.h"


typedef enum : NSInteger
{
    CBCFeedFilterMe = 0,
    CBCFeedFilterCollective
} CBCFeedFilter;

typedef enum : NSInteger
{
    CBCFeedSourceCoreData = 0,
    CBCFeedSourceMedable
} CBCFeedSource;

@interface CBCFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIButton *medableLoggedInButton;
@property (weak, nonatomic) IBOutlet UIButton *goToMedableButton;
@property (weak, nonatomic) IBOutlet UIButton *medableInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *resetTrialModeButton;

@property (strong, nonatomic) IBOutlet UISegmentedControl *feedFilterControl;

@property (assign, nonatomic) CBCFeedFilter currentFeedFilter;
@property (assign, nonatomic) CBCFeedSource currentFeedSource;

@property (nonatomic, strong) NSArray* data;

- (IBAction)feedFilterChanged:(id)sender;
- (IBAction)medableInfoTouched:(id)sender;
- (IBAction)goToMedableTouched:(id)sender;
- (IBAction)resetTrialModeTouched:(id)sender;

- (void)feedSourceDidChange;

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
    
    [self updateEditButton];
    [self updateMedableLoggedIn];
    
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(updateMedableLoggedIn) name:kMDNotificationUserDidLogin object:nil];
    
    self.currentFeedFilter = CBCFeedFilterMe;
    self.currentFeedSource = CBCFeedSourceMedable;
    
    self.feedFilterControl.selectedSegmentIndex = self.currentFeedFilter;
    
    // Testing Facebook
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.center = self.view.center;
//    [self.view addSubview:loginView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isMovingToParentViewController == NO)
    {
        // we're already on the navigation stack
        // another controller must have been popped off
        [self updateMedableLoggedIn];
    }
    
    [self feedSourceDidChange];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMedableLoggedIn
{
    BOOL inTrialMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"InTrialMode"];
    
    BOOL loggedIn = ([[MDAPIClient sharedClient] localUser] != nil);
    self.medableLoggedInButton.enabled = loggedIn;
    [self.feedFilterControl setEnabled:loggedIn forSegmentAtIndex:CBCFeedFilterCollective];
    
    // when in trial mode, the medableInfoButton brings up info on medable
    // when in full medable mode, the goToMedableButton takes the user directly
    // to the Medable settings page
    self.goToMedableButton.userInteractionEnabled = !inTrialMode;
    self.medableInfoButton.userInteractionEnabled = inTrialMode;

#ifdef DEBUG
    self.resetTrialModeButton.enabled = !inTrialMode;
#endif

    self.currentFeedSource = (inTrialMode) ? CBCFeedSourceCoreData : CBCFeedSourceMedable;
    [self feedSourceDidChange];
    
    if (!inTrialMode)
    {
        self.fetchedResultsController.delegate = nil;
    }
}

- (void)updateEditButton
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    
    UITableView *tableView = [self tableView];
    if (![tableView isEditing] || numberOfObjects == 0)
    {
        [self.editButton setTitle:@"Edit"];
    }
    else
    {
        [self.editButton setTitle:@"Done"];
    }
    
    [self.editButton setEnabled:(numberOfObjects != 0)];
}


#pragma mark - Core Data Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    CBCAppDelegate *appDelegate = [CBCAppDelegate appDelegate];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HeartRateEvent" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // NB: nil for section name key path means "no sections".
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:fetchRequest
                                              managedObjectContext:appDelegate.managedObjectContext
                                                sectionNameKeyPath:nil
                                                         cacheName:@"Master"];
    controller.delegate = self;
    self.fetchedResultsController = controller; // sets _fetchedResultsController
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //NSLog(@"controllerWillChangeContent:\n");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    //NSLog(@"controller:didChangeSection:\n");

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
    //NSLog(@"controller:didChangeObject:\n");
    
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
    //NSLog(@"controllerDidChangeContent:\n");
    [self.tableView endUpdates];
    [self updateEditButton];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 0;
    
    switch (self.currentFeedSource)
    {
        case CBCFeedSourceMedable:
            numberOfSections = 1;
            break;
            
        case CBCFeedSourceCoreData:
            numberOfSections = [[self.fetchedResultsController sections] count];
            break;
            
        default:
            break;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSInteger numberOfRows = 0;
    
    switch (self.currentFeedSource)
    {
        case CBCFeedSourceMedable:
            numberOfRows = [self.data count];
            break;
            
        case CBCFeedSourceCoreData:
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
            numberOfRows = [sectionInfo numberOfObjects];
        }
            break;
            
        default:
            break;
    }
    
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
    if (self.currentFeedSource == CBCFeedSourceMedable)
    {
        MDPost* post = [self.data objectAtIndex:indexPath.row];
        
        if (post.typeEnumerated == MDPostTypeHeartrate)
        {
            NSUInteger heartbeat = 0;
            
            NSArray* body = [post body];
            for (NSDictionary* bodyDict in body)
            {
                NSString* segmentType = [bodyDict objectForKey:kTypeKey];
                if ([segmentType isEqualToString:kIntegerKey])
                {
                    NSNumber* heartbeatNumber = [bodyDict objectForKey:kValueKey];
                    heartbeat = [heartbeatNumber unsignedIntegerValue];
                }
            }
            
            cell.textLabel.text = [NSDateFormatter
                                   localizedStringFromDate:post.created
                                   dateStyle:NSDateFormatterMediumStyle
                                   timeStyle:NSDateFormatterShortStyle];
            
            cell.imageView.image = [UIImage imageNamed:@"tabbar_heartrate"]; // cells are reused so it could have the image of another post, remove it
            
            [post postPicsWithUpdateBlock:^BOOL(NSString *imageId, UIImage *image, BOOL lastImage)
             {
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    cell.imageView.image = image;
                                });
                 
                 return YES;
             }];
            
        }
    }
    else if (self.currentFeedSource == CBCFeedSourceCoreData)
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
        if (self.currentFeedSource == CBCFeedSourceCoreData)
        {
            // Delete the row from the data source
            //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
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
        else if (self.currentFeedSource == CBCFeedSourceMedable)
        {
            // Delete from Medable
            MDPost* post = [self.data objectAtIndex:indexPath.row];
            
            NSString* creatorId = nil;
            if ([post.creator isExpanded])
            {
                creatorId = [post.creator.value objectForKey:kIDKey];
            }
            else
            {
                creatorId = post.creator.value;
            }
            
            if ([creatorId isEqualToString:[[MDAPIClient sharedClient] localUser].Id])
            {
                [[MDAPIClient sharedClient]
                 deletePostWithId:post.Id
                 commentId:nil
                 callback:^(MDFault *fault)
                 {
                     if (fault)
                     {
                         [[CBCAppDelegate appDelegate] displayAlertWithMedableFault:fault];
                     }
                 }];
            }
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CBCDetailViewController *detailController = [segue destinationViewController];
    NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];

    if (self.currentFeedSource == CBCFeedSourceCoreData)
    {
        CBCHeartRateEvent * event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        detailController.displayedEvent = event;
        detailController.displayedPost = nil;
    }
    else if (self.currentFeedSource == CBCFeedSourceMedable)
    {
        MDPost* selectedPost = [self.data objectAtIndex:indexPath.row];
        detailController.displayedPost = selectedPost;
        detailController.displayedEvent = nil;
    }
}

- (IBAction)resetTrialModeTouched:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"InTrialMode"];
    [self updateMedableLoggedIn];
}

- (IBAction)medableInfoTouched:(id)sender
{
    NSLog(@"medableInfoTouched:");

    NSString * message = [NSString stringWithCString:
        "Secure your heart rate data with Medable.\n"
        "Create an account or log in to unlock all\n"
        "of the features of Biogram.\n"
        "https://www.medable.com"
        encoding:NSUTF8StringEncoding];
    
    UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:@"Medable"
                          message:message
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self goToMedableTouched:self];
}

- (IBAction)goToMedableTouched:(id)sender
{
    NSLog(@"goToMedableTouched:");

    // go to settings tab
    self.tabBarController.selectedIndex = 2;

    // go to medable settings page
    UINavigationController * settingsNavControl = self.tabBarController.viewControllers[2];
    UIViewController * settingsControl = settingsNavControl.childViewControllers[0];
    if (![settingsNavControl.visibleViewController.restorationIdentifier isEqualToString:@"medableMainTableViewController"])
    {
        [settingsControl performSegueWithIdentifier:@"goToMedableSettingsSegue" sender:self];

    }
}

#pragma mark - Segmented controls

- (IBAction)feedFilterChanged:(id)sender
{
    self.currentFeedFilter = self.feedFilterControl.selectedSegmentIndex;
    [self feedSourceDidChange]; // I suppose this is all we need
}

- (void)feedSourceDidChange
{
    switch (self.currentFeedSource)
    {
        case CBCFeedSourceCoreData:
            [self.tableView reloadData];
            break;
            
        case CBCFeedSourceMedable:
            [self updateMedableFeed];
            break;
            
        default:
            NSLog(@"Invalid feed source!");
            break;
    }
}


#pragma mark - Medable feed

- (void)updateMedableFeed
{
    if (self.currentFeedSource == CBCFeedSourceMedable)
    {
        switch (self.currentFeedFilter)
        {
            case CBCFeedFilterCollective:
                [self listCollectiveFeed];
                break;
                
            case CBCFeedFilterMe:
                [self listFeed];
                break;
                
            default:
                break;
        }
    }
}

- (void)listFeed
{
    if (self.currentFeedSource == CBCFeedSourceMedable)
    {
        __weak typeof (self) wSelf = self;
        
        MDAccount* currentAccount = [MDAPIClient sharedClient].localUser;
        if (currentAccount)
        {
            NSString* biogramId = [currentAccount biogramId];
            
            [[MDAPIClient sharedClient]
             listFeedWithBiogramId:biogramId
             parameters:nil
             callback:^(NSArray *feed, MDFault *fault)
             {
                 if (!fault)
                 {
                     wSelf.data = feed;
                     [wSelf.tableView reloadData];
                 }
             }];
        }
    }
}

- (void)listCollectiveFeed
{
    if (self.currentFeedSource == CBCFeedSourceMedable)
    {
        __weak typeof (self) wSelf = self;
        
        MDAPIClient* apiClient = [MDAPIClient sharedClient];
        
        // Current account
        MDAccount* currentAccount = apiClient.localUser;
        if (currentAccount)
        {
            // i.e. First Page
            // GET /feed/biogram/53e29340247fdb7b5c00010e?contexts[]=biogram&postTypes=heartrate&filterCaller=true&limit=2
            
            MDAPIParameters* contextsParameter = [MDAPIParameterFactory parametersWithContexts:@[ kBiogramKey ]];
            MDAPIParameters* postTypeParameter = [MDAPIParameterFactory parametersWithIncludePostTypes:@[ kHeartrateKey ] excludePostTypes:nil];
            MDAPIParameters* filterCallerParameter = [MDAPIParameterFactory parametersWithFilterCaller:YES];
            MDAPIParameters* limitParameter = [MDAPIParameterFactory parametersWithLimitResultsTo:2];
            
            MDAPIParameters* parameters = [MDAPIParameterFactory parametersWithParameters:
                                           contextsParameter,
                                           postTypeParameter,
                                           filterCallerParameter,
                                           limitParameter,
                                           nil];
            
            // GET /feed?contexts[]=biogram&postTypes=heartrate&filterCaller=true
            [[MDAPIClient sharedClient]
             listFeedWithBiogramId:[currentAccount biogramId]
             parameters:parameters
             callback:^(NSArray *feed, MDFault *fault)
             {
                 if (!fault)
                 {
                     wSelf.data = feed;
                     [wSelf.tableView reloadData];
                 }
             }];
        }
    }
}

@end
