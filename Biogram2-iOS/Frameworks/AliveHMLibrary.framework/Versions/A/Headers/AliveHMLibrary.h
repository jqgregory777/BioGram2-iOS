//
// AliveHMLibrary.h
// AliveCor Heart Rate Monitoring iOS Framework
// This library supports the iPhone 3.2 and later
//
// Created by Kim Barnett on 5/02/10.
// Copyright 2010 AliveCor Inc. All rights reserved.
//
#if !defined(__AliveHMLibrary_h__)
#define __AliveHMLibrary_h__

#if defined(__cplusplus)
extern "C"
{
#endif

			
typedef UInt32	AliveHMStatus;
enum {
	kAliveHMStatusBeginInterruption = 0, 
	kAliveHMStatusEndInterruption = 1,
	kAliveHMStatusStopped = 2, // Session stopped
	kAliveHMStatusStarted = 3, // Session started
	kAliveHMStatusLeadsOn = 4, // Leads on
	kAliveHMStatusLeadsOff = 5 // Leads off
};

    
// AliveHMHeartRateListener callback function to receive 1sec fixed interval heart rate measurements.
// To receive heart rate events the client application must set this callback function in AliveHMSetHeartRateListener.
// It will be called once per second.
//   outClientData: The client user data provided in the AliveHMSetHeartRateListener    
//	 outHeartRate: Heart rate in bpm. A value < 30 indicates that the heart rate can not be determined.
typedef void (*AliveHMHeartRateListener)(void * outClientData, double outHeartRate);

// AliveHMHeartBeatListener callback function to receive heart beat events.
// To receive heart beat events the client application must set this callback function in AliveHMSetHeartBeatListener.
// It will be called when each heart beat (QRS) is detected.
//   outClientData: The client user data provided in the AliveHMSetHeartBeatListener 
//   outTime: The elasped time from the start of a monitoring session in ms.
//   outHeartRate: The current heart rate in bpm.  
//	 outRRInterval: The last RR interval in ms. It will have a value of 0 for first beat detected.
typedef void (*AliveHMHeartBeatListener)(void * outClientData, unsigned int outTime, double outHeartRate, unsigned int outRRInterval);	

// AliveHMSetStatusListener callback function to receive monitoring status changes.
// To receive status changes the client application must set this callback function in AliveHMSetStatusListener.
//   outClientData: The client user data provided in the AliveHMSetStatusListener 
//   outStatus: Status of the monitoring session.  
typedef void (*AliveHMStatusListener)(void * outClientData, AliveHMStatus outStatus);	



// AliveHMInitialize initializes the Heart Rate monitoring session.
// This function has to be called once before calling any other AliveHM functions.
extern bool AliveHMInitialize();

// AliveHMSetMainsFreqFilter sets the Mains Frequency Filter to 50 or 60Hz.
// This removes any mains interference from the ECG signal, which in some circumstances can disrupt the heart rate measurement
// The default filter is set to 60Hz.
//   inMainsFreq: Mains Frequency, 50 or 60
extern void AliveHMSetMainsFilterFreq(int inMainsFreq);
    
// AliveHMSetHeartRateListener
//   inListener: AliveHMHeartRateListener callback. It will be called once per second, with the current heart rate.
//   inClientData: The client user data to use when calling the AliveHMHeartRateListener.
extern void AliveHMSetHeartRateListener(AliveHMHeartRateListener inListener, void *inClientData);
	
// AliveHMSetHeartBeatListener
//   inListener: AliveHMHeartBeatListener callback. It will be called when each heart beat (QRS) is detected.
//   inClientData: The client user data to use when calling the AliveHMHeartBeatListener
extern void AliveHMSetHeartBeatListener(AliveHMHeartBeatListener inListener, void *inClientData);	

// AliveHMSetStatusListener
//   inListener: A AliveHMStatusListener callback. It will be called whenever the monitoring status changes.
//   inClientData: The client user data to use when calling the AliveHMStatusListener
extern void AliveHMSetStatusListener(AliveHMStatusListener inListener, void *inClientData);	
	
// Stops a Heart Rate monitoring session and frees resources.
extern void AliveHMUninitialize();

// Starts a Heart Rate monitoring session
extern bool AliveHMStart();

// Stops a Heart Rate monitoring session
extern void AliveHMStop();

#ifdef __cplusplus
}
#endif

#endif /* __AliveHMLibrary_h__ */