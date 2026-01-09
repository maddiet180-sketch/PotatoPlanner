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
    @EnvironmentObject var potatoViewModel: PotatoPlannerModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var elapsedSeconds: Int = 0
    @State private var isRunning: Bool = true
    
    let task: Task
    
    private let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            counter
            Text("You've got this!")
                .font(.subheadline)
            Spacer()
            Button {
                potatoViewModel.finishSession()
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.accentColor1A)
                        .frame(width: 70, height: 40)
                    Text("Pause")
                }
            }
        }
        .fontWeight(.heavy)
        .padding()
        .background(.textboxBackground)
        .foregroundStyle(.primaryText)
        .onAppear {
            elapsedSeconds = 0
            isRunning = true
            potatoViewModel.startSession(task: task)
        }
        .onReceive(timer) {_ in
            guard isRunning else { return }
            elapsedSeconds += 1
            
            let totalCompletedSeconds = task.totalSeconds(including: elapsedSeconds)
            
            if task.allocatedSeconds <= totalCompletedSeconds {
                isRunning = false
                potatoViewModel.finishSession()
                dismiss()
            }
        }
    }
    
    var counter: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.0)
                .fill(Color(.accentColor3))
//                .stroke(.accentColor3B, lineWidth: 3)
                .frame(width: 350, height: 150)
                .shadow(color: Color(.systemGray3), radius: 4.0)
                .padding()
            Text(timeRemianing)
                .font(.largeTitle.bold())
                .foregroundStyle(.textboxBackground)
        }
    }
    
    var timeRemianing: String {
        (task.totalRemainingSeconds(including: elapsedSeconds)).asHHMMSS
    }
}

#Preview {
    FocusView(task: .preview)
        .environmentObject(PotatoPlannerModel())
}
