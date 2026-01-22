import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()

    var body: some View {
        TabView {
            LogView()
                .tabItem {
                    Image(systemName: "bed.double")
                    Text("Log")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("History")
                }

            OptionsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Options")
                }
        }
        .environmentObject(dataManager)
    }
}

#Preview {
    ContentView()
}
