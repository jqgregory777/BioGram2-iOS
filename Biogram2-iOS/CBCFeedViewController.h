//
//  CBCFeedViewController.h
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBCFeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITabBarDelegate, UIAlertViewDelegate>

- (void)stopEditingTableView;

@end
