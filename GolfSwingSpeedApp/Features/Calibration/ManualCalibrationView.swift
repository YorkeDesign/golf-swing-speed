import SwiftUI

struct ManualCalibrationView: View {
    @Bindable var calibrationManager: CalibrationManager
    @State private var distanceInput = ""
    @State private var distanceUnit: DistanceInputUnit = .metres
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Instructions
                instructionText

                // Calibration canvas
                calibrationCanvas

                // Distance input (when both points set)
                if calibrationManager.needsDistance {
                    distanceInputSection
                }

                // Done button
                if calibrationManager.isCalibrated {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .navigationTitle("Calibrate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") { calibrationManager.reset() }
                }
            }
        }
    }

    // MARK: - Instruction Text

    @ViewBuilder
    private var instructionText: some View {
        if calibrationManager.needsFirstPoint {
            Label("Tap the first reference point", systemImage: "1.circle")
                .font(.headline)
        } else if calibrationManager.needsSecondPoint {
            Label("Tap the second reference point", systemImage: "2.circle")
                .font(.headline)
        } else if calibrationManager.needsDistance {
            Label("Enter the distance between the two points", systemImage: "ruler")
                .font(.headline)
        } else if calibrationManager.needsImpactZone {
            Label("Tap the ball/impact zone position", systemImage: "target")
                .font(.headline)
        } else if calibrationManager.isCalibrated {
            Label("Calibration complete", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.green)
        }
    }

    // MARK: - Calibration Canvas

    private var calibrationCanvas: some View {
        GeometryReader { geometry in
            ZStack {
                // Placeholder for camera preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.3))
                    .overlay {
                        Text("Camera Preview")
                            .foregroundStyle(.secondary)
                    }

                // Tap points
                if let p1 = calibrationManager.firstPoint {
                    CalibrationMarker(position: p1, label: "1", color: .blue)
                }
                if let p2 = calibrationManager.secondPoint {
                    CalibrationMarker(position: p2, label: "2", color: .blue)
                }
                if let impact = calibrationManager.impactZone {
                    CalibrationMarker(position: impact, label: "X", color: .red)
                }

                // Line between reference points
                if let p1 = calibrationManager.firstPoint, let p2 = calibrationManager.secondPoint {
                    Path { path in
                        path.move(to: p1)
                        path.addLine(to: p2)
                    }
                    .stroke(.blue.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                handleTap(at: location)
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
    }

    // MARK: - Distance Input

    private var distanceInputSection: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Distance", text: $distanceInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)

                Picker("Unit", selection: $distanceUnit) {
                    Text("m").tag(DistanceInputUnit.metres)
                    Text("ft").tag(DistanceInputUnit.feet)
                    Text("cm").tag(DistanceInputUnit.centimetres)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }

            Button("Confirm Distance") {
                if let value = Double(distanceInput), value > 0 {
                    let metres = distanceUnit.toMetres(value)
                    calibrationManager.setKnownDistance(metres)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Tap Handling

    private func handleTap(at location: CGPoint) {
        if calibrationManager.needsFirstPoint {
            calibrationManager.setFirstPoint(location)
        } else if calibrationManager.needsSecondPoint {
            calibrationManager.setSecondPoint(location)
        } else if calibrationManager.needsImpactZone {
            calibrationManager.setImpactZone(location)
        }
    }
}

// MARK: - Calibration Marker

struct CalibrationMarker: View {
    let position: CGPoint
    let label: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 32, height: 32)
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: 32, height: 32)
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .position(position)
    }
}

// MARK: - Distance Unit

enum DistanceInputUnit: String, CaseIterable {
    case metres, feet, centimetres

    func toMetres(_ value: Double) -> Double {
        switch self {
        case .metres: return value
        case .feet: return value * 0.3048
        case .centimetres: return value / 100.0
        }
    }
}

#Preview {
    ManualCalibrationView(calibrationManager: CalibrationManager())
}
