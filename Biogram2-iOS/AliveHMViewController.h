//
//  AliveHMViewController.h
//  biogram
//
//  Created by Neel Bhoopalam on 4/12/14.
//  Copyright (c) 2014 USC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AliveCompletionHandler)(NSString *inputText);


@protocol AliveHMDelegate <NSObject>

-(void)didCloseAliveViewWithHeartRate:(NSString*)heartRate;
-(void)didAbortAliveView;

@end

@interface AliveHMViewController : UIViewController
{
    UILabel *lblMeasuring;
    UILabel *lblHeartRate;
    UILabel *lblLastHeartRate;
    UILabel *twoDigitBPM;
	UIImageView *imgHeart;
	UIImageView *imgLeadsOn;
    UIImageView *imgHRInstructions;
    //UIBarButtonItem *buttonBack;
    UIBarButtonItem *buttonConfirm;
	double _heartRate;
	bool _heartBeat;
	id _lock;
}


@property (copy, nonatomic) AliveCompletionHandler completionHandler;

@property (retain, nonatomic) IBOutlet UILabel *lblMeasuring;
@property (retain, nonatomic) IBOutlet UILabel *lblHeartRate;
@property (retain, nonatomic) IBOutlet UILabel *lblLastHeartRate;
@property (retain, nonatomic) IBOutlet UILabel *twoDigitBPM;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *buttonConfirm;
//@property (retain, nonatomic) IBOutlet UIBarButtonItem *buttonBack;
@property (retain, nonatomic) IBOutlet UIImageView *imgHRInstructions;
@property (retain, nonatomic) IBOutlet UIImageView *imgHeart;
@property (retain, nonatomic) IBOutlet UIImageView *imgLeadsOn;



@property (retain, nonatomic) NSObject <AliveHMDelegate> *delegate;

@end
