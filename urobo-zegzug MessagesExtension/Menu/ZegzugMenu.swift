import SwiftUI

struct ZegzugMenu: View {
    @StateObject var viewModel: ZegzugGameViewModel
    @State var rotation = 0

    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 20) {
                    Text("Pebble count:")
                        .fontWeight(.bold)
                    Text("\(Int(viewModel.numOfPebbles))")
                    Slider(value: $viewModel.numOfPebbles, in: 6 ... 12, step: 1)
                        .tint(.monochromeButton)
                }

                HStack(spacing: 20) {
                    Text("Board rotation:")
                        .fontWeight(.bold)
                    Picker("Asd", selection: $rotation) {
                        Text("Random").tag(0)
                        Text("Custom").tag(1)
                    }
                    .pickerStyle(.segmented)
                }

                if rotation == 1 {
                    HStack(spacing: 20) {
                        Text("\(Int(viewModel.rotationValue))")
                        Slider(value: $viewModel.rotationValue, in: 0 ... 11, step: 1)
                            .tint(.monochromeButton)
                        Text("sections")
                    }
                }

                Button("Start game") {
                    viewModel.sendAction(isInitial: true, isRotationRandom: rotation == 0)
                }
                .buttonStyle(.monochromeShadow)
                .frame(minHeight: 100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
    }
}
