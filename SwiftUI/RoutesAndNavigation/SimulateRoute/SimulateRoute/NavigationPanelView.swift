// SPDX-FileCopyrightText: 2026 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import SwiftUI
import GEMKit

// MARK: - Navigation Panel View

struct NavigationPanelView: View {
    @ObservedObject var model: SimulateRouteModel
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 2.5) {
            // Turn information row
            TurnInfoView(model: model)

            // Lane panel
            LanePanelView(model: model)

            // Traffic panel
            TrafficPanelView(model: model)

            // Safety camera panel
            SafetyPanelView(model: model)

            // Social reports panel
            ReportsPanelView(model: model)
        }
        .padding(.bottom, 2.5)
        .background(Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .gray, radius: 3)
        .overlay(alignment: .topTrailing) {
            Button(action: onStop) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.red)
                    .background(Circle().fill(.black))
            }
            .offset(x: 8, y: -8)
        }
    }
}

// MARK: - Turn Info View

struct TurnInfoView: View {
    @ObservedObject var model: SimulateRouteModel

    var body: some View {
        let instruction = model.navigationInstruction

        HStack(spacing: 0) {
            // Turn image + distance
            VStack(spacing: 0) {
                if let instruction = instruction {
                    let scale = UIScreen.main.scale
                    let size = CGSize(width: 60 * scale, height: 60 * scale)
                    if let img = instruction.getNextTurnImage(
                        size,
                        colorActiveInner: .white,
                        colorActiveOuter: .black,
                        colorInactiveInner: .lightGray,
                        colorInactiveOuter: .lightGray)
                    {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }

                    let dist = instruction.getDistanceToNextTurnFormatted()
                    let distUnit = instruction.getDistanceToNextTurnUnitFormatted()
                    (Text(dist).font(.system(size: 24, weight: .bold))
                        + Text(distUnit).font(.system(size: 14, weight: .bold)))
                        .foregroundStyle(.white)
                        .frame(height: 30)
                }
            }
            .frame(width: 80)

            // Turn instruction text + signpost
            VStack(spacing: 0) {
                if let instruction = instruction {
                    // Signpost
                    let spScale = UIScreen.main.scale
                    let spHeight: CGFloat = 100 * spScale
                    let spSize = CGSize(width: 2.5 * spHeight, height: spHeight)
                    let spBorder = Int(5 * spScale)

                    if let spImg = instruction.getSignpostImage(spSize, border: spBorder, roundCorners: true, rows: 3) {
                        Image(uiImage: spImg)
                            .resizable()
                            .scaledToFit()
                    } else {
                        // Road code + instruction text
                        let instrText = instruction.getNextTurnInstructionFormatted()

                        if let roadImg = roadCodeImage(instruction: instruction) {
                            Image(uiImage: roadImg)
                                .resizable()
                                .scaledToFit()
                                .frame(height: instrText.isEmpty ? 80 : 40)
                        }

                        if !instrText.isEmpty {
                            Text(instrText)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 110)
    }

    private func roadCodeImage(instruction: NavigationInstructionObject) -> UIImage? {
        let scale = UIScreen.main.scale
        let height: CGFloat = 80 * scale
        let size = CGSize(width: 2.5 * height, height: height)

        if instruction.hasNextRoadInfo() {
            return instruction.getNextRoadCodeImage(size)
        } else if instruction.hasCurrentRoadInfo() {
            return instruction.getCurrentRoadCodeImage(size)
        }
        return nil
    }
}

// MARK: - Lane Panel View

struct LanePanelView: View {
    @ObservedObject var model: SimulateRouteModel

    var body: some View {
        let instruction = model.navigationInstruction
        let scale = UIScreen.main.scale

        if let instruction = instruction {
            let laneSize = CGSize(width: 300 * scale, height: 60 * scale)
            if let img = instruction.getLaneImage(
                laneSize,
                backgroundColor: .black,
                activeColor: .white,
                inactiveColor: .lightGray)
            {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(uiColor: .darkGray), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 2.5)
            }
        }
    }
}

// MARK: - Traffic Panel View

struct TrafficPanelView: View {
    @ObservedObject var model: SimulateRouteModel

    var body: some View {
        let info = trafficInfo()

        if let info = info {
            HStack(spacing: 5) {
                Image(uiImage: info.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 2) {
                    Text(info.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(1)

                    Text(info.details)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 5)
            .frame(height: 60)
            .background(Color(red: 255 / 255, green: 175 / 255, blue: 63 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 2.5)
        }
    }

    private struct TrafficInfo {
        let image: UIImage
        let title: String
        let details: String
    }

    private func trafficInfo() -> TrafficInfo? {
        guard let instruction = model.navigationInstruction,
              let remainingDist = instruction.getRemainingTravelTimeDistance()?.getTotalDistance(),
              let route = model.mainRoute
        else { return nil }

        let events = route.getTrafficEvents()
        let scale = UIScreen.main.scale
        let size = CGSize(width: 60 * scale, height: 60 * scale)

        for event in events {
            if event.hasTrafficEvent(onDistance: remainingDist) {
                guard let img = event.getImage(size) else { continue }

                let title = event.getDescription()
                var parts: [String] = []

                let dist = event.getDistanceFormatted()
                let distUnit = event.getDistanceUnitFormatted()
                if !dist.isEmpty { parts.append(dist + distUnit) }

                let delay = event.getDelayTimeFormatted()
                let delayUnit = event.getDelayTimeUnitFormatted()
                if !delay.isEmpty { parts.append(delay + delayUnit) }

                let delayDist = event.getDelayDistanceFormatted()
                let delayDistUnit = event.getDelayDistanceUnitFormatted()
                if !delayDist.isEmpty { parts.append(delayDist + delayDistUnit) }

                return TrafficInfo(image: img, title: title, details: parts.joined(separator: "  "))
            }
        }
        return nil
    }
}

// MARK: - Safety Camera Panel View

struct SafetyPanelView: View {
    @ObservedObject var model: SimulateRouteModel

    var body: some View {
        if let info = safetyInfo() {
            HStack(spacing: 5) {
                Image(uiImage: info.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                Text(info.details)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 5)
            .frame(height: 60)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 2.5)
        }
    }

    private struct SafetyInfo {
        let image: UIImage
        let details: String
    }

    private func safetyInfo() -> SafetyInfo? {
        let scale = UIScreen.main.scale
        let height: CGFloat = 50 * scale

        for item in model.alarmItems {
            let identifier = CommonOverlayIdentifier(rawValue: item.getOverlayUid())
            if identifier == .safety, let img = item.getAspectRatioImage(height),
               let alarmContext = model.alarmContext {
                let dist = alarmContext.getDistanceFormatted(with: item)
                let distUnit = alarmContext.getDistanceUnitFormatted(with: item)
                return SafetyInfo(image: img, details: dist + distUnit)
            }
        }
        return nil
    }
}

// MARK: - Social Reports Panel View

struct ReportsPanelView: View {
    @ObservedObject var model: SimulateRouteModel

    var body: some View {
        if let info = reportsInfo() {
            HStack(spacing: 5) {
                Image(uiImage: info.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                Text(info.details)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 5)
            .frame(height: 60)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 2.5)
        }
    }

    private struct ReportsInfo {
        let image: UIImage
        let details: String
    }

    private func reportsInfo() -> ReportsInfo? {
        let scale = UIScreen.main.scale
        let height: CGFloat = 50 * scale

        for item in model.alarmItems {
            let identifier = CommonOverlayIdentifier(rawValue: item.getOverlayUid())
            if identifier == .socialReports, let img = item.getAspectRatioImage(height),
               let alarmContext = model.alarmContext {
                let dist = alarmContext.getDistanceFormatted(with: item)
                let distUnit = alarmContext.getDistanceUnitFormatted(with: item)
                return ReportsInfo(image: img, details: dist + distUnit)
            }
        }
        return nil
    }
}
