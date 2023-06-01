import SwiftUI

struct ZegzugMenu: View {
    @StateObject var viewModel: ZegzugGameViewModel
    @State var rotation = 0

    let backAction: () -> Void

    var body: some View {
        ScrollView {
            VStack {
                backButton()
                pebbleSlider()
                boardRotationPicker()
                boardRotationAmountSlider()
                startButton()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
    }

    @ViewBuilder private func backButton() -> some View {
        HStack {
            Button {
                backAction()
            } label: {
                Image(systemName: "arrow.left")
            }
            .frame(maxWidth: 30)
            .buttonStyle(.circular)
            Spacer()
        }
    }

    @ViewBuilder private func pebbleSlider() -> some View {
        HStack(spacing: 20) {
            Text("Pebble count:")
                .fontWeight(.bold)
            Text("\(Int(viewModel.numOfPebbles))")
            Slider(value: $viewModel.numOfPebbles, in: 6 ... 12, step: 1)
                .tint(.monochromeButton)
        }
    }

    @ViewBuilder private func boardRotationPicker() -> some View {
        HStack(spacing: 20) {
            Text("Board rotation:")
                .fontWeight(.bold)
            Picker("Rotation", selection: $rotation) {
                Text("Random").tag(0)
                Text("Custom").tag(1)
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder private func boardRotationAmountSlider() -> some View {
        if rotation == 1 {
            HStack(spacing: 20) {
                Text("\(Int(viewModel.rotationValue))")
                Slider(value: $viewModel.rotationValue, in: 0 ... 11, step: 1)
                    .tint(.monochromeButton)
                Text("sections")
            }
        }
    }

    @ViewBuilder private func startButton() -> some View {
        Button("Start game") {
            viewModel.sendAction(isInitial: true, isRotationRandom: rotation == 0)
        }
        .buttonStyle(.monochromeShadow)
        .frame(minHeight: 100)
    }
}
