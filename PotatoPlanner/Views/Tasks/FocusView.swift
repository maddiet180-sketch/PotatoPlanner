//
//  FocusView.swift
//  PotatoPlanner
//
//  Created by Maddie Moody on 12/9/25.
//

import SwiftUI
internal import Combine

struct FocusView: View {
    @Environment(PotatoPlannerStore.self) var store
    @Environment(\.dismiss) private var dismiss

    let taskID: UUID

    private var task: TaskEntity? {
        store.tasks.first { $0.id == taskID }
    }

    private var elapsedSeconds: Int { store.sessionInfo.elapsedSeconds }
    private var isPaused: Bool { store.sessionInfo.isPaused }

    @State private var isRunning: Bool = true
    @State private var sessionResult: SessionResult?
    @State private var isShowingResult: Bool = false
    @State private var isShowingLevelUp: Bool = false

    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        ZStack {
            Color(.textboxBackground)
                .ignoresSafeArea()

            FocusBackgroundVideo(
                duration: Double(task?.allocatedSeconds ?? 0),
                initialProgress: Double((task?.completedSeconds ?? 0)),
                isPaused: isPaused
            )
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
            guard sessionResult == nil, let task else { return }
            store.startSession(for: task)
        }
        .onReceive(timer) { _ in
            guard isRunning, !isPaused else { return }
            store.sessionInfo.elapsedSeconds += 1
            finishSessionIfComplete()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            guard !isPaused else { return }
            store.sessionInfo.enterBackgroundDate = Date.now
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            guard let enterDate = store.sessionInfo.enterBackgroundDate else { return }
            store.sessionInfo.elapsedSeconds += Int(Date.now.timeIntervalSince(enterDate))
            store.sessionInfo.enterBackgroundDate = nil
            finishSessionIfComplete()
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
                if let result = store.finishSession(with: finalFocusedSeconds) {
                    sessionResult = result
                    isShowingResult = true
                }
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
            Text(timeRemaining)
                .font(.custom("Myfont-Regular", size: 45))
                .textShadow(x: 4, y: 4, color: .primaryText)
                .foregroundStyle(.textboxBackground)
                .padding(.top)
        }
    }

    var timeRemaining: String {
        guard let task else { return "0:00:00" }
        return task.totalRemainingSeconds(including: finalFocusedSeconds).asHHMMSS
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
            store.sessionInfo.isPaused = true
        } label: {
            ZStack {
                Circle()
                    .fill(.accentColor3B)
                    .frame(width: 50)
                Image(systemName: "pause")
                    .font(.title3)
            }
        }
        .disabled(isPaused)
        .opacity(isPaused ? 0.5 : 1)
    }

    var startButton: some View {
        Button {
            store.sessionInfo.isPaused = false
        } label: {
            ZStack {
                Circle()
                    .fill(.accentColor3B)
                    .frame(width: 50)
                Image(systemName: "play")
                    .font(.title3)
            }
        }
        .disabled(!isPaused)
        .opacity(isPaused ? 1 : 0.5)
    }

    private var finalFocusedSeconds: Int {
        guard let task else { return elapsedSeconds }
        return min(task.secondsToComplete, elapsedSeconds)
    }

    private func finishSessionIfComplete() {
        guard let task else { return }
        guard task.allocatedSeconds <= task.totalSeconds(including: finalFocusedSeconds) else { return }
        isRunning = false
        if let result = store.finishSession(with: finalFocusedSeconds) {
            sessionResult = result
            withAnimation(.easeOut(duration: 0.3)) { isShowingResult = true }
        }
    }
}

#Preview {
    FocusView(taskID: TaskEntity.preview.id)
        .environment(PotatoPlannerStore.preview)
}
