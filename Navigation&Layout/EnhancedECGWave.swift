//
//  CardioLoadingView.swift
//  DrRajaMed
//
//  Created by Jonathan Hidrogo on 4/19/25.
//

import SwiftUI

struct EnhancedECGWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height / 2
        
        // Start from left baseline
        path.move(to: CGPoint(x: 0, y: height))
        
        // Initial baseline
        path.addLine(to: CGPoint(x: width * 0.05, y: height))
        
        // P Wave: more subtle and rounded
        path.addQuadCurve(
            to: CGPoint(x: width * 0.15, y: height),
            control: CGPoint(x: width * 0.1, y: height * 0.85)
        )
        
        // PR segment (flat)
        path.addLine(to: CGPoint(x: width * 0.22, y: height))
        
        // Q Wave: small downward deflection
        path.addLine(to: CGPoint(x: width * 0.23, y: height * 1.1))
        
        // R Wave: sharp upstroke
        path.addLine(to: CGPoint(x: width * 0.24, y: height * 0.2))
        
        // R to S: quick downstroke
        path.addLine(to: CGPoint(x: width * 0.26, y: height * 1.3))
        
        // S to end of QRS: return toward baseline
        path.addLine(to: CGPoint(x: width * 0.28, y: height * 1.05))
        
        // ST segment (slightly elevated)
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.95))
        
        // T Wave: more realistic dome shape
        path.addQuadCurve(
            to: CGPoint(x: width * 0.45, y: height),
            control: CGPoint(x: width * 0.4, y: height * 0.7)
        )
        
        // Baseline until next beat
        path.addLine(to: CGPoint(x: width * 0.6, y: height))
        
        // Second heartbeat (similar pattern but slightly varied)
        // P Wave
        path.addQuadCurve(
            to: CGPoint(x: width * 0.7, y: height),
            control: CGPoint(x: width * 0.65, y: height * 0.85)
        )
        
        // PR segment
        path.addLine(to: CGPoint(x: width * 0.77, y: height))
        
        // QRS complex
        path.addLine(to: CGPoint(x: width * 0.78, y: height * 1.1))
        path.addLine(to: CGPoint(x: width * 0.79, y: height * 0.2))
        path.addLine(to: CGPoint(x: width * 0.81, y: height * 1.3))
        path.addLine(to: CGPoint(x: width * 0.83, y: height * 1.05))
        
        // ST segment
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.95))
        
        // T Wave
        path.addQuadCurve(
            to: CGPoint(x: width, y: height),
            control: CGPoint(x: width * 0.95, y: height * 0.7)
        )
        
        return path
    }
}

// Modified version of your original loading view to use the enhanced ECG wave
struct EnhancedECGLoadingView: View {
    @State private var phase: CGFloat = 0
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
                    .padding(.bottom, -5)
                    .offset(y: 60)
                
                EnhancedECGWave()
                    .trim(from: 0, to: phase)
                    .stroke(colors[colorIndex], lineWidth: 4)
                    .frame(width: 300, height: 200)
                    .animation(.linear(duration: 2), value: phase)
                    .offset(y: 100)
            }
        }
        .onAppear {
            startAnimation()
            typeLoadingText()
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 2)) {
            phase = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            phase = 0
            colorIndex = (colorIndex + 1) % colors.count
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startAnimation()
            }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    typeLoadingText()
                }
            }
        }
    }
}
