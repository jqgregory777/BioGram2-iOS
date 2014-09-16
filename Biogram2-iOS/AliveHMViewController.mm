//
//  AliveHMViewController.m
//  biogram
//
//  Created by Neel Bhoopalam on 4/12/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import "AliveHMViewController.h"
#import <AliveHMLibrary/AliveHMLibrary.h>

@interface AliveHMViewController ()
@end

@implementation AliveHMViewController

@synthesize lblHeartRate;
@synthesize lblLastHeartRate;
@synthesize lblMeasuring;
@synthesize twoDigitBPM;
@synthesize imgHeart;
@synthesize imgLeadsOn;
@synthesize imgHRInstructions;
@synthesize buttonConfirm;
//@synthesize buttonBack;


BOOL hasInitialized = false;
BOOL foundHR = false;


void heartRateCallback(void *clientData, double heartRate)
{
	AliveHMViewController *THIS = (AliveHMViewController *)clientData;
	@synchronized(THIS->_lock)
	{
		if(heartRate==0 && THIS->_heartRate !=0) {
			THIS->_heartRate = 0;
			
			// Note: Can't update UI in background audio thread. UI must be updated in the main thread.
			[THIS performSelectorOnMainThread:@selector(updateHeartRate) withObject:nil waitUntilDone:NO];
		}
	}
}

void heartBeatCallback(void *clientData, unsigned int time_ms, double heartRate, unsigned int rrInterval_ms)
{
	AliveHMViewController *THIS = (AliveHMViewController *)clientData;
	@synchronized(THIS->_lock)
	{
		THIS->_heartRate = heartRate;
	}
	// Note: Can't update UI in background audio thread. UI must be updated in the main thread.
	[THIS performSelectorOnMainThread:@selector(updateHeartRate) withObject:nil waitUntilDone:NO];
	
	// Note: Can't update UI in background audio thread. UI must be updated in the main thread.
	[THIS performSelectorOnMainThread:@selector(heartBeat) withObject:nil waitUntilDone:NO];
}

void statusCallback(void *clientData, AliveHMStatus status)
{
	AliveHMViewController *THIS = (AliveHMViewController *)clientData;
	switch (status) {
		case kAliveHMStatusBeginInterruption:
			// AliveHMSession has been interrupted, for example when there is a phone call. It will re-start automatically.
            //			NSLog(@"AliveHMTest: AliveHMStatusBeginInterruption\n");
			break;
		case kAliveHMStatusEndInterruption:
			// Interruption has ended. AliveHMSession will start automatically.
            //			NSLog(@"AliveHMTest: AliveHMStatusEndInterruption\n");
			break;
		case kAliveHMStatusStarted:
			// AliveHMSession has started.
            //			NSLog(@"AliveHMTest: AliveHMStatusStarted\n");
            @try {
                [THIS performSelectorOnMainThread:@selector(updateStatusStarted) withObject:nil waitUntilDone:NO];
            } @catch (NSException *e) {
                //                NSLog(@"AliveHMTest: AliveHMStatusStarted caught exception\n");
            }
			break;
		case kAliveHMStatusStopped:
			// AliveHMSession has stopped. This will occur when there is an kAudioSessionProperty_AudioRouteChange
			// such as when you remove the headset cable.  Note that AliveHMSession will re-start automatically when
			// the cable is plugged in. On the iPod we get kAliveHMStatusStarted->kAliveHMStatusStopped->kAliveHMStatusStarted,
			// because kAudioSessionProperty_AudioRouteChange occurs after starting.
            //			NSLog(@"AliveHMTest: AliveHMStatusStopped\n");
            @try {
                [THIS performSelectorOnMainThread:@selector(updateStatusStopped) withObject:nil waitUntilDone:NO];
            } @catch (NSException *e) {
                //  NSLog(@"AliveHMTest: AliveHMStatusStopped caught exception\n");
            }
			break;
		case kAliveHMStatusLeadsOn:
			// We have a signal from the heart monitor
			//NSLog(@"AliveHMTest: AliveHMStatusLeadsOn\n");
			[THIS performSelectorOnMainThread:@selector(setLeadsOn) withObject:nil waitUntilDone:NO];
			break;
		case kAliveHMStatusLeadsOff:
			// No signal from the heart monitor
			//NSLog(@"AliveHMTest: AliveHMStatusLeadsOff\n");
			[THIS performSelectorOnMainThread:@selector(setLeadsOff) withObject:nil waitUntilDone:NO];
			break;
		default:
			break;
	}
}

- (void)updateStatusStopped
{
	lblHeartRate.enabled = false;
}

- (void)updateStatusStarted
{
	lblHeartRate.enabled = true;
}

- (void)heartBeat
{
	// Flash Heart image for 200ms on the heart beat label
    // lblHeartRate.hidden = false;
	[self performSelector:@selector(heartBeatTimeout) withObject:nil afterDelay:(NSTimeInterval)0.2];
}

- (void)heartBeatTimeout
{
	//imgHeart.hidden = true;
    // twoDigitBPM.hidden = true;
    // lblHeartRate.hidden = true;
}

- (void)setLeadsOn
{
	imgLeadsOn.hidden = false;
    lblMeasuring.hidden = false;
    imgHRInstructions.hidden = true;
    
}

- (void)setLeadsOff
{
	imgLeadsOn.hidden = true;
}

- (void)updateHeartRate
{
	double heartRate = 0.0;
    NSString *hr = @"";
    
	@synchronized(_lock) {
		heartRate = _heartRate;
	}
	if (heartRate>=30.0) {
        if(heartRate>=100.0){
            hr = [[NSString alloc] initWithFormat:@"%.0lf", heartRate];
            self.twoDigitBPM.hidden = true;
            lblLastHeartRate.text = hr;
            [self.buttonConfirm setEnabled:YES];
        }
        else {
            hr = [[NSString alloc] initWithFormat:@"%.0lf ", heartRate];
            self.twoDigitBPM.hidden = false;
            lblLastHeartRate.text = [hr substringToIndex:2];
            [self.buttonConfirm setEnabled:YES];

        }
        foundHR = true;
        
        lblHeartRate.text = hr;
        
        
        [hr release];
	} else {
        // heart rate Unknown
        if (foundHR){
            imgHeart.hidden = false;
        }
        else {
            lblHeartRate.text = @"---";
        }
	}
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *finalHeartRate = lblLastHeartRate.text;
    [_delegate didCloseAliveViewWithHeartRate:finalHeartRate];
}

//- (IBAction)confirmButtonPressed:(id)sender {
//    NSString *finalHeartRate = lblLastHeartRate.text;
//    [_delegate didCloseAliveViewWithHeartRate:finalHeartRate];
//}
//
//
//
//- (IBAction)backButtonPressed:(id)sender {
//    [_delegate didCloseAliveViewWithoutHeartRate];
//}

- (void)setup {
    // Non-UI initialization goes here. It will only ever be called once.
    if (!hasInitialized){
        AliveHMInitialize();
        AliveHMSetMainsFilterFreq(50);
        AliveHMSetStatusListener(statusCallback, self);
        AliveHMSetHeartBeatListener(heartBeatCallback, self);
        AliveHMSetHeartRateListener(heartRateCallback, self);
        
        AliveHMStart();
        hasInitialized = true;
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    AliveHMUninitialize();
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
    // Any UI-related configuration goes here. It may be called multiple times,
    // but each time it is called, `self.view` will be freshly loaded from the nib
    // file.
    [super viewDidLoad];
    [self.buttonConfirm setEnabled:NO];
    
	lblHeartRate.text = @"---";
}

- (void)viewDidUnload {
    // Set all IBOutlets to `nil` here.
    // Drop any lazy-load data that you didn't drop in viewWillDisappear:
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [super viewDidUnload];
    
    
    //	AliveHMUninitialize();
    self.lblHeartRate = nil;
    self.imgHeart = nil;
    self.imgLeadsOn = nil;
    self.lblLastHeartRate = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Most data loading should go here to make sure the view matches the model
    // every time it's put on the screen. This is also a good place to observe
    // notifications and KVO, and to setup timers.
    
    [self setup];
}


- (BOOL)shouldAutorotate
{
    return YES;
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Unregister from notifications and KVO here (balancing viewWillAppear:).
    // Stop timers.
    // This is a good place to tidy things up, free memory, save things to
    // the model, etc.
    if (hasInitialized){
        AliveHMStop();
        AliveHMUninitialize();
        hasInitialized = false;
    }
}

- (void)dealloc {
    // Don't unregister KVO here. Observe and remove KVO in viewWill(Dis)appear.
    
    [lblHeartRate release];
    [imgHeart release];
	[imgLeadsOn release];
    [lblLastHeartRate release];
    [twoDigitBPM release];
    [lblMeasuring release];
    [buttonConfirm release];
    //[buttonBack release];
    [imgHRInstructions release];
    [super dealloc];
}

@end
