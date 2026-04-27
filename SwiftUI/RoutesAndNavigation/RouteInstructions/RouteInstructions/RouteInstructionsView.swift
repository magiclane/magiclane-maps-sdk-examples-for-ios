// SPDX-FileCopyrightText: 2021-2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

// MARK: - Instruction Data Item

struct InstructionItem: Identifiable {

    let id = UUID()
    let title: String
    let description: String
    let image: UIImage?
    let statusText: String
    let statusDescription: String
    let sortKey: Int

    // Only one of these will be set
    let routeInstruction: RouteInstructionObject?
    let routeTrafficEvent: RouteTrafficEventObject?
}

// MARK: - Route Instructions View

struct RouteInstructionsView: View {

    let route: RouteObject

    @Binding var selectedItem: InstructionItem?
    @Binding var showInstructions: Bool

    @State private var items: [InstructionItem] = []

    var body: some View {
        List(items) { item in
            Button {
                selectedItem = item
                showInstructions = false
            } label: {
                InstructionRow(item: item)
            }
            .tint(.primary)
        }
        .listStyle(.plain)
        .navigationTitle("Route Instructions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            items = prepareItems()
        }
    }

    // MARK: - Prepare Data

    private func prepareItems() -> [InstructionItem] {

        var result: [InstructionItem] = []

        let scale = UIScreen.main.scale
        let imgSize = CGSize(width: 40.0 * scale, height: 40.0 * scale)

        // 1 — Route instructions (turns + follow road)

        let segmentList = route.getSegments()

        for segment in segmentList {

            let instructionList = segment.getInstructions()

            for routeInstruction in instructionList {

                var title = ""
                var description = ""
                var statusText = ""
                var statusDescription = ""
                var sortKey = 0
                var image: UIImage?

                if routeInstruction.hasTurnInfo() {
                    title = routeInstruction.getTurnInstruction()
                }

                if routeInstruction.hasFollowRoadInfo() {
                    description = routeInstruction.getFollowRoadInstruction()
                }

                if let timeDistance = routeInstruction.getTraveledTimeDistance() {
                    statusText = timeDistance.getTotalDistanceFormatted()
                    statusDescription = timeDistance.getTotalDistanceUnitFormatted()
                    sortKey = Int(timeDistance.getTotalDistance())
                }

                if let turn = routeInstruction.getTurnDetails() {
                    image = turn.getTurnImage(
                        imgSize,
                        colorActiveInner: UIColor.black,
                        colorActiveOuter: UIColor.white,
                        colorInactiveInner: UIColor.lightGray,
                        colorInactiveOuter: UIColor.lightGray)
                }

                result.append(InstructionItem(
                    title: title,
                    description: description,
                    image: image,
                    statusText: statusText,
                    statusDescription: statusDescription,
                    sortKey: sortKey,
                    routeInstruction: routeInstruction,
                    routeTrafficEvent: nil
                ))
            }
        }

        // 2 — Traffic events

        if let timeDistance = route.getTimeDistance() {

            let routeLength = timeDistance.getTotalDistance()
            let trafficEvents = route.getTrafficEvents()

            for event in trafficEvents {

                if event.hasTrafficEvent(onDistance: routeLength) {

                    let image = event.getImage(imgSize)

                    let distance = event.getDistanceFormatted()
                    let distanceUnit = event.getDistanceUnitFormatted()

                    let delay = event.getDelayTimeFormatted()
                    let delayUnit = event.getDelayTimeUnitFormatted()

                    let delayDistance = event.getDelayDistanceFormatted()
                    let delayDistanceUnit = event.getDelayDistanceUnitFormatted()

                    let eventDescription = event.getDescription()

                    let title = delay + delayUnit + ", " + delayDistance + delayDistanceUnit + " (" + eventDescription + ")"

                    var description = ""

                    if let from = event.getFromLandmark(), !from.getLandmarkName().isEmpty {
                        description = from.getLandmarkName()
                    }

                    if let to = event.getToLandmark(), !to.getLandmarkName().isEmpty {
                        description += "\n" + to.getLandmarkName()
                    }

                    let sortKey = Int(routeLength) - Int(event.getDistanceToDestination())

                    result.append(InstructionItem(
                        title: title,
                        description: description,
                        image: image,
                        statusText: distance,
                        statusDescription: distanceUnit,
                        sortKey: sortKey,
                        routeInstruction: nil,
                        routeTrafficEvent: event
                    ))
                }
            }

            if !trafficEvents.isEmpty {
                result.sort { $0.sortKey < $1.sortKey }
            }
        }

        return result
    }
}

// MARK: - Instruction Row

struct InstructionRow: View {

    let item: InstructionItem

    var body: some View {
        HStack(spacing: 12) {

            // Turn / traffic icon
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }

            // Title + description
            VStack(alignment: .leading, spacing: 2) {

                if !item.title.isEmpty {
                    Text(item.title)
                        .font(.body)
                }

                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Distance status (accessory)
            VStack(alignment: .trailing, spacing: 2) {

                if !item.statusText.isEmpty {
                    Text(item.statusText)
                        .font(.body)
                }

                if !item.statusDescription.isEmpty {
                    Text(item.statusDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 60)
        }
        .padding(.vertical, 4)
    }
}
