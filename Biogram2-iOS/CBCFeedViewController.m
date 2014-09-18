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

@interface CBCFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

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
    [self updateEditButton];
    
    // Testing Facebook
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.center = self.view.center;
//    [self.view addSubview:loginView];
    
    // Log in to Medable
    if (![[MDAPIClient sharedClient] localUser])
    {
        [[CBCAppDelegate appDelegate] showMedableLoginDialog];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    CBCAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

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

    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
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
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedProtoCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:indexPath
{
    CBCHeartRateEvent * event = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:event.timeStamp
                                                         dateStyle:NSDateFormatterMediumStyle
                                                         timeStyle:NSDateFormatterShortStyle];
    
    UIImage * thumbnail = event.thumbnail;
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
        cell.imageView.image = thumbnail;
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
    NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
    CBCHeartRateEvent * event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    detailController.displayedEvent = event;
}

@end
