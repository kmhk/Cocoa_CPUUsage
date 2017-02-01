//
//  AppDelegate.h
//  HardwareInformation
//
//  Created by Com on 01/02/2017.
//  Copyright © 2017 Com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/mach.h>
#include <mach/processor_info.h>
#include <mach/mach_host.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	processor_info_array_t cpuInfo, prevCpuInfo;
	mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
	unsigned numCPUs;
	NSTimer *updateTimer;
	NSLock *CPUUsageLock;
}

@property (nonatomic) NSMutableArray *arrayCPUs;

@end

