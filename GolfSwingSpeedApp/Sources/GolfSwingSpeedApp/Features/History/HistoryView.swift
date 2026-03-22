import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \SwingRecord.timestamp, order: .reverse) private var swings: [SwingRecord]
    @State private var selectedClubFilter: ClubType?

    var body: some View {
        NavigationStack {
            Group {
                if swings.isEmpty {
                    emptyState
                } else {
                    swingList
                }
            }
            .navigationTitle("History")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Swings Yet",
            systemImage: "figure.golf",
            description: Text("Captured swings will appear here. Go to the Capture tab to record your first swing.")
        )
    }

    // MARK: - Swing List

    private var swingList: some View {
        List {
            ForEach(swings) { swing in
                NavigationLink {
                    SwingDetailView(swing: swing)
                } label: {
                    SwingRowView(swing: swing)
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Swing Row

struct SwingRowView: View {
    let swing: SwingRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(swing.club.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Spacer()

                    if let speed = swing.impactSpeedMph {
                        Text("\(speed.formattedSpeed) mph")
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    } else {
                        Text("--")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Text(swing.timestamp.mediumDateString)
                    Text(swing.timestamp.shortTimeString)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            confidenceIndicator
        }
    }

    private var confidenceIndicator: some View {
        Circle()
            .fill(confidenceColor)
            .frame(width: 10, height: 10)
    }

    private var confidenceColor: Color {
        if swing.confidenceScore > 0.7 { return .green }
        if swing.confidenceScore > 0.4 { return .yellow }
        return .red
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: SwingRecord.self, inMemory: true)
}
