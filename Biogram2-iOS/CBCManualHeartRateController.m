//
//  CBCManualHeartRateController.m
//  Biogram2-iOS
//
//  Created by Jason Gregory on 9/13/14.
//  Copyright (c) 2014 USC Center for Body Computing. All rights reserved.
//

#import "CBCManualHeartRateController.h"
#import "CBCAppDelegate.h"
#import "CBCHeartRateEvent.h"

@interface CBCManualHeartRateController ()
@property (weak, nonatomic) IBOutlet UIPickerView *heartRatePicker;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (strong, nonatomic) NSMutableArray *pickableHeartRates;

@end

@implementation CBCManualHeartRateController

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

    self.pickableHeartRates = [[NSMutableArray alloc] init];
    
    for (int i = 50; i <= 150; i++)
    {
        [self.pickableHeartRates addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    [self.heartRatePicker selectRow:20 inComponent:0 animated:YES];
    self.heartRateLabel.text = [self.pickableHeartRates objectAtIndex:20];

    //
    // Create a new pending heart rate event (for manual entry)
    //
    
    CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate beginCreatingHeartRateEvent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickableHeartRates count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [self.pickableHeartRates objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.heartRateLabel.text = [self.pickableHeartRates objectAtIndex:row];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"manualHeartRateSegue"])
    {
        NSString *finalHeartRate = self.heartRateLabel.text;

        CBCAppDelegate *appDelegate = (CBCAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.pendingHeartRateEvent.heartRate = finalHeartRate;
    }
}

@end
