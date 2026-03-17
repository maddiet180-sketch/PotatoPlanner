//
//  FocusView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import SwiftUI
internal import Combine
import WebKit

struct FocusView: View {
    @Environment(PotatoPlannerStore.self) var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var elapsedSeconds: Int = 0
    @State private var isRunning: Bool = true
    @State private var sessionResult: SessionResult?
    @State private var isShowingResult: Bool = false
    @State private var isShowingLevelUp: Bool = false
    
    let task: TaskEntity
    
    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        let videoDuration = Double(task.allocatedSeconds - task.completedSeconds)
        
        ZStack {
            Color(.textboxBackground)
                .ignoresSafeArea()
            
            FocusBackgroundVideo(duration: videoDuration)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                exitButton
                Spacer()
                counter
                Text("You've got this!")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                Spacer()
                counterActionButtons
            }
            .fontWeight(.heavy)
            .padding()
        }
        .foregroundStyle(.primaryText)
        .onAppear {
            elapsedSeconds = 0
            isRunning = true
            store.startSession(for: task)
        }
        .onReceive(timer) {_ in
            guard isRunning else { return }
            elapsedSeconds += 1

            if task.allocatedSeconds <= task.totalSeconds(including: elapsedSeconds) {
                isRunning = false
                sessionResult = store.finishSession(with: elapsedSeconds)
                isShowingResult = true
            }
        }
        .onChange(of: isShowingResult) { _, newValue in
            if !newValue {
                if sessionResult?.levelsGained == true {
                    isShowingLevelUp = true
                } else {
                    withAnimation(.bouncy()) { dismiss() }
                }
            }
        }
        .onChange(of: isShowingLevelUp) { _, newValue in
            if !newValue {
                withAnimation(.bouncy()) { dismiss() }
            }
        }
        .overlay {
            if isShowingResult, let result = sessionResult {
                ZStack {
                    Color.primaryText.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture { isShowingResult = false }
                    FocusRewardPopup(isShowing: $isShowingResult, result: result)
                }
            }
        }
        .overlay {
            if isShowingLevelUp {
                ZStack {
                    Color.primaryText.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture { isShowingLevelUp = false }
                    PotatoLevelUpPopup(isShowing: $isShowingLevelUp)
                }
            }
        }
    }
    
    var exitButton: some View {
        HStack {
            Button {
                isRunning = false
                sessionResult = store.finishSession(with: elapsedSeconds)
                isShowingResult = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.textboxBackground)
                        .frame(width: 50)
                    Image(systemName: "arrowshape.turn.up.backward.circle.fill")
                        .font(.largeTitle)
                }
            }
            Spacer()
        }
    }
    
    var counter: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.0)
                .fill(Color(.accentColor3B))
                .frame(width: 250, height: 100)
                .shadow(color: Color(.systemGray3), radius: 4.0)
            Text(timeRemianing)
                .font(.largeTitle.bold())
                .foregroundStyle(.textboxBackground)
                .textStroke(width: 0.5, color: .primaryText)
        }
    }
    
    var timeRemianing: String {
        (task.totalRemainingSeconds(including: elapsedSeconds)).asHHMMSS
    }
    
    var counterActionButtons: some View {
        HStack {
            pauseButton
            startButton
        }
        .padding()
    }
    
    var pauseButton: some View {
        Button {
            isRunning = false
            
        } label: {
            ZStack {
                Circle()
                    .fill(.accentColor3B)
                    .frame(width: 50)
                Image(systemName: "pause")
                    .font(.title3)
            }
        }
        .disabled(!isRunning)
        .opacity(isRunning ? 1 : 0.7)
    }
    
    var startButton: some View {
        Button {
            isRunning = true
            
        } label: {
            ZStack {
                Circle()
                    .fill(.accentColor3B)
                    .frame(width: 50)
                Image(systemName: "play")
                    .font(.title3)
            }
        }
        .disabled(isRunning)
        .opacity(isRunning ? 0.7 : 1)
    }
}

#Preview {
    FocusView(task: .preview)
        .environment(PotatoPlannerStore.preview)  
}
