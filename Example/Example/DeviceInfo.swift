//
//  DeviceInfo.swift
//  Example
//
//  Created by KK Systems on 2022/09/19.
//

#if os(macOS)
import Foundation
import IOKit
import IOKit.ps
import Chronograph

struct DeviceInfo {
	enum BatteryError: Error { case error }
	
	static var batteryLevel: Double {
		do {
			// Take a snapshot of all the power source info
			guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
			else { throw BatteryError.error }
			
			// Pull out a list of power sources
			guard let sources: NSArray = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue()
			else { throw BatteryError.error }
			
			// For each power source...
			for ps in sources {
				// Fetch the information for a given power source out of our snapshot
				guard let info: NSDictionary = IOPSGetPowerSourceDescription(snapshot, ps as CFTypeRef)?.takeUnretainedValue()
				else { throw BatteryError.error }
				
				// Pull out the name and current capacity
				if let capacity = info[kIOPSCurrentCapacityKey] as? Int,
				   let max = info[kIOPSMaxCapacityKey] as? Int {
					return Double(capacity) / Double(max)
				}
			}
		} catch {
			fatalError()
		}
		
		return 0
	}
	
	static var batteryState: BatteryState {
		do {
			// Take a snapshot of all the power source info
			guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
			else { throw BatteryError.error }
			
			// Pull out a list of power sources
			guard let sources: NSArray = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue()
			else { throw BatteryError.error }
			
			// For each power source...
			for ps in sources {
				// Fetch the information for a given power source out of our snapshot
				guard let info: NSDictionary = IOPSGetPowerSourceDescription(snapshot, ps as CFTypeRef)?.takeUnretainedValue()
				else { throw BatteryError.error }
				
				guard let capacity = info[kIOPSCurrentCapacityKey] as? Int,
					  let max = info[kIOPSMaxCapacityKey] as? Int,
					  let powerSource = info[kIOPSPowerSourceStateKey] as? String
				else { throw BatteryError.error }
				
				let isCharging = powerSource == kIOPSACPowerValue
				
				print(info)
				
				if isCharging && capacity >= max {
					return .full
				} else if isCharging {
					return .charging
				} else {
					return .unplugged
				}
			}
		} catch {
			fatalError()
		}
		
		return .unknown
	}
}
#endif
