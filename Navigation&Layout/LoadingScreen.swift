//
//  Loading Screen.swift
//  DrRaja Prototype #3
//
//  Created by Jonathan Hidrogo on 3/22/25.
//

import SwiftUI

struct ECGLoadingView: View {
    @State private var phase: CGFloat = 0
    @State private var isReversing = false
    @State private var colorIndex: Int = 0
    @State private var displayedText = ""
    
    let fullText = "/Loading. . ."
    let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .orange, .cyan]

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Background
            
            VStack {
                Text(displayedText)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.bottom, -5) // Keep title slightly closer to wave
                    .offset(y: 60) // Moves the text down
                
                ECGWave()
                    .trim(from: 0, to: phase)
                    .stroke(colors[colorIndex], lineWidth: 4)
                    .animation(.linear(duration: 2), value: phase)
                    .offset(y: 100) // Moves the wave down
            }
        }
        .onAppear {
            startForwardAnimation()
            typeLoadingText()
        }
    }

    private func startForwardAnimation() {
        isReversing = false
        withAnimation(.linear(duration: 2)) {
            phase = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            startReverseAnimation()
        }
    }

    private func startReverseAnimation() {
        isReversing = true
        withAnimation(.linear(duration: 2)) {
            phase = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            colorIndex = (colorIndex + 1) % colors.count
            startForwardAnimation()
        }
    }

    private func typeLoadingText() {
        displayedText = ""
        var index = 0

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if index < fullText.count {
                let charIndex = fullText.index(fullText.startIndex, offsetBy: index)
                displayedText.append(fullText[charIndex])
                index += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Pause, then restart
                    typeLoadingText()
                }
            }
        }
    }
}

struct ECGWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height / 2

        let peakCenter = width * 0.5 // Center R peak below "Loading..."

        // **Start baseline at the very left**
        path.move(to: CGPoint(x: 0, y: height))

        // **P Wave: Smooth hill**
        path.addQuadCurve(
            to: CGPoint(x: width * 0.14, y: height * 0.85),
            control: CGPoint(x: width * 0.07, y: height * 0.75)
        )

        // **Flat baseline before Q wave**
        path.addLine(to: CGPoint(x: width * 0.18, y: height * 0.95))

        // **Q Wave: Quick dip**
        path.addQuadCurve(
            to: CGPoint(x: width * 0.22, y: height * 1.15),
            control: CGPoint(x: width * 0.2, y: height * 1.2)
        )

        // **R Wave: Tall, sharp peak centered**
        path.addLine(to: CGPoint(x: peakCenter - (width * 0.05), y: height * 0.05))
        path.addLine(to: CGPoint(x: peakCenter + (width * 0.05), y: height * 1.3))

        // **S Wave: Slightly wider before rising sharply**
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 1.15)) // Slightly more width
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 1.05)) // Steep rise

        // **Flat ST segment before T wave**
        path.addLine(to: CGPoint(x: width * 0.72, y: height * 1.05))

        // **T Wave: Slightly larger**
        path.addQuadCurve(
            to: CGPoint(x: width, y: height),
            control: CGPoint(x: width * 0.85, y: height * 0.7)
        )

        return path
    }
}



struct ECGLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ECGLoadingView()
    }
}
