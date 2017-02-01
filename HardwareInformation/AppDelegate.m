//
//  AppDelegate.m
//  HardwareInformation
//
//  Created by Com on 01/02/2017.
//  Copyright © 2017 Com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	int mib[2U] = { CTL_HW, HW_NCPU };
	size_t sizeOfNumCPUs = sizeof(numCPUs);
	int status = sysctl(mib, 2U, &numCPUs, &sizeOfNumCPUs, NULL, 0U);
	if(status)
		numCPUs = 1;
	
	self.arrayCPUs = [[NSMutableArray alloc] init];
	for (int i = 0; i < numCPUs; i ++) {
		NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(5, 5 + i * 50, 300, 40)];
		[self.window.contentView addSubview:textField];
		[self.arrayCPUs addObject:textField];
	}
	
	CPUUsageLock = [[NSLock alloc] init];
	
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:3
													target:self
												  selector:@selector(updateInfo:)
												  userInfo:self
												   repeats:YES];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


- (void)updateInfo:(NSTimer *)timer
{
//	AppDelegate *appdel = (AppDelegate *)(timer.userInfo);
	
	natural_t numCPUsU = 0U;
	kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
	if(err == KERN_SUCCESS) {
		[CPUUsageLock lock];
		
		for(unsigned i = 0U; i < numCPUs; ++i) {
			float inUse, total;
			if(prevCpuInfo) {
				inUse = (
						 (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
						 + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
						 + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
						 );
				total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
			} else {
				inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
				total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
			}
			
			NSString *text = [NSString stringWithFormat:@"Core: %u Usage: %f",i,inUse / total];
			NSLog(@"Core: %u Usage: %f",i,inUse / total);
			[self.arrayCPUs[i] setStringValue:text];
		}
		[CPUUsageLock unlock];
		
		if(prevCpuInfo) {
			size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
			vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
		}
		
		prevCpuInfo = cpuInfo;
		numPrevCpuInfo = numCpuInfo;
		
		cpuInfo = NULL;
		numCpuInfo = 0U;
	} else {
		NSLog(@"Error!");
		[NSApp terminate:nil];
	}
}


@end
