//
//  WorkoutManager.swift
//  targetpace Watch App
//
//  Created by admin on 4/10/24.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    var selectedWorkout: HKWorkoutActivityType? {
        didSet {
            guard let selectedWorkout = selectedWorkout else { return }
            startWorkout(workoutType: selectedWorkout)
        }
    }
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    // Start the workout collection.
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor
        
        // Create the session and obtain the workout builder.
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            return
        }
        
        // Setup session and builder.
        session?.delegate = self
        builder?.delegate = self
        
        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                      workoutConfiguration: configuration)
        
        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            // The workout has started.
        }
    }
    
    @Published var authorizationGranted = false
    
    // The quantity type to write to the health store.
    let typesToShare: Set<HKSampleType> = [
        HKQuantityType.workoutType()
    ]
    
    // The quantity types to read from the health store.
    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    ]
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            // Request authorization for those quantity types.
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                // Handle error.
                if success {
                    print("Authorization granted")
                    DispatchQueue.main.async {
                        self.checkAuthorizationStatus()
                    }
                } else {
                    print("Authorization denied or error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // Check required authorization granted
    func checkAuthorizationStatus() {
        authorizationGranted = isAuthorizationGranted()
        if authorizationGranted {
            selectedWorkout = .running
        }
    }
    
    func isAuthorizationGranted() -> Bool {
        for type in typesToShare {
            let authorizationStatus = healthStore.authorizationStatus(for: type)
            if authorizationStatus != .sharingAuthorized {
                print("Write access denied")
                return false
            }
        }
        
        for type in typesToRead {
            let authorizationStatus = healthStore.authorizationStatus(for: type)
            if authorizationStatus == .notDetermined {
                print("Read access not determined: \(type)")
                return false
            }
        }
        return true;
    }
    
    // MARK: - Session State Control
    
    // The app's workout state.
    @Published var running = false
    
    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }
    
    func pause() {
        session?.pause()
    }
    
    func resume() {
        session?.resume()
    }
    
    func endWorkout() {
        session?.end()
    }
    
    // MARK: - Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    @Published var pace: TimeInterval = 0
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        print("Updating")
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            default:
                return
            }
            // Convert distance to kilometers
            let distanceInKm = self.distance / 1000
            
            // Calculate pace in seconds per kilometer
            let paceInSecondsPerKm = self.getElapsedTime() ?? 0 / distanceInKm
            self.pace = paceInSecondsPerKm / 60
            print(self.running, self.distance, self.activeEnergy)
        }
    }
    
    func getElapsedTime() -> TimeInterval? {
        guard let startDate = self.builder?.startDate else {
            return nil
        }
        let currentTime = Date()
        return currentTime.timeIntervalSince(startDate)
    }
    
    func resetWorkout() {
        selectedWorkout = nil
        builder = nil
        workout = nil
        session = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
        pace = 0
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        print(toState)
        DispatchQueue.main.async {
            self.running = toState == .running
            print("Running")
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed with error: \(error.localizedDescription)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}
