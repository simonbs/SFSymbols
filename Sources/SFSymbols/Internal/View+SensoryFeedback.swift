import SwiftUI

extension View {
    @ViewBuilder
    func selectionSensoryFeedback<T: Equatable>(trigger: T) -> some View {
        #if os(visionOS)
        if #available(visionOS 26, *) {
            sensoryFeedback(.selection, trigger: trigger)
        } else {
            self
        }
        #else
        sensoryFeedback(.selection, trigger: trigger)
        #endif
    }
}
