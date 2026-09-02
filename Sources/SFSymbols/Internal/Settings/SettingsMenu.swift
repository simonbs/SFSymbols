import SwiftUI

struct SettingsMenu: View {
    @Binding var symbolBackgroundSetting: SymbolBackgroundSetting

    var body: some View {
        Menu {
            Picker(selection: $symbolBackgroundSetting) {
                ForEach(SymbolBackgroundSetting.allCases) { setting in
                    Text(setting.title)
                }
            } label: {
                Text("Background", bundle: .module)
            }
            .pickerStyle(.inline)
        } label: {
            Label {
                Text("Settings", bundle: .module)
            } icon: {
                Image(systemName: "ellipsis")
            }
            .labelStyle(.iconOnly)
        }
    }
}
