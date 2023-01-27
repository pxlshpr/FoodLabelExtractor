import SwiftUI
import Popovers
import SwiftHaptics

extension AttributesLayer {
    
    @ViewBuilder
    var tutorialLayer: some View {
        if showingTutorial {
            TutorialLayer() {
                withAnimation(.interactiveSpring()) {
                    showingTutorial = false
                }
            }
        }
    }
}

enum TutorialStep: String {
    case edit
    case checkboxes
    case add
    case done
    
    var message: String {
        switch self {
        case .edit:
            return "Edit any incorrectly detected nutrients."
        case .checkboxes:
            return "Use these to mark and keep track of what you've confirmed to be correct."
        case .add:
            return "Add missing nutrients if needed."
        case .done:
            return "Fill in the nutrients once confirmed."
        }
    }
}

struct TutorialLayer: View {
    @State var step: String?
    
    let didTapDismiss: (() -> ())
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
//            Color.black.opacity(0.1)
//                .onTapGesture {
//                    Haptics.feedback(style: .soft)
//                    didTapDismiss()
//                }
                
//            Color.blue.opacity(0.5)
            HStack(spacing: 0) {
                Spacer()
                Color.clear
                    .frame(width: 100)
                    .padding(.trailing, K.Cell.checkBoxButtonWidth)
                    .popover(
                        selection: $step,
                        tag: TutorialStep.edit.rawValue,
                        attributes: {
                            $0.sourceFrameInset.top = -8
//                            $0.sourceFrameInset.right = 20
                            $0.position = .absolute(
                                originAnchor: .top,
                                popoverAnchor: .bottom
                            )
                            $0.onDismiss = {
                                didTapDismiss()
                            }
                        }
                    ) {
                        Templates.Container(
                            arrowSide: .bottom(.mostCounterClockwise),
                            backgroundColor: .accentColor
                        ) {
                            Button {
                                Haptics.feedback(style: .soft)
                                step = TutorialStep.add.rawValue
                            } label: {
                                HStack {
                                    Text(TutorialStep.edit.message)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.forward.circle.fill")
                                        .foregroundColor(.white.opacity(0.75))
                                }
                            }
                        }
//                        .clipped()
                        .frame(maxWidth: 250)
                    }
            }
            .frame(height: K.attributesLayerHeight - K.topButtonPaddedHeight)
                        
            HStack(spacing: 0) {
                Spacer()
//                Color.yellow
                Color.clear
                    .frame(width: 20)
                    .popover(
                        selection: $step,
                        tag: TutorialStep.add.rawValue,
                        attributes: {
                            $0.sourceFrameInset.top = -3
//                            $0.sourceFrameInset.right = -20
                            $0.screenEdgePadding = .init(top: 0, left: 0, bottom: 0, right: -5)
                            $0.position = .absolute(
                                originAnchor: .topLeft,
                                popoverAnchor: .bottom
                            )
                            $0.onDismiss = {
                                didTapDismiss()
                            }
                        }
                    ) {
                        Templates.Container(
                            arrowSide: .bottom(.mostCounterClockwise),
                            backgroundColor: .accentColor
                        ) {
                            Button {
                                Haptics.feedback(style: .soft)
                                step = TutorialStep.checkboxes.rawValue
                            } label: {
                                HStack {
                                    Text(TutorialStep.add.message)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.forward.circle.fill")
                                        .foregroundColor(.white.opacity(0.75))
                                }
                            }
                        }
                        .frame(maxWidth: 250)
                    }
                    .padding(.trailing, 50)
                    .padding(.bottom, 120)
            }
            .frame(height: 50)
            
            HStack(spacing: 0) {
                Spacer()
//                Color.yellow
                Color.clear
                    .frame(width: K.Cell.checkBoxButtonWidth)
                    .padding(.trailing, 0)
                    .popover(
                        selection: $step,
                        tag: TutorialStep.checkboxes.rawValue,
                        attributes: {
//                            $0.sourceFrameInset.top = -8
                            $0.sourceFrameInset.left = 0
                            $0.position = .absolute(
                                originAnchor: .left,
                                popoverAnchor: .right
                            )
                            $0.onDismiss = {
                                didTapDismiss()
                            }
                        }
                    ) {
                        Templates.Container(
                            arrowSide: .right(.centered),
                            backgroundColor: .accentColor
                        ) {
                            Button {
                                Haptics.feedback(style: .soft)
                                step = TutorialStep.done.rawValue
                            } label: {
                                HStack {
                                    Text(TutorialStep.checkboxes.message)
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.forward.circle.fill")
                                        .foregroundColor(.white.opacity(0.75))
                                }
                            }
                        }
                        .frame(maxWidth: 250)
                    }
                    .padding(.bottom, 285)
            }
            .frame(height: K.attributesLayerHeight - K.topButtonPaddedHeight)

            VStack {
                HStack(spacing: 0) {
                    Spacer()
//                    Color.yellow
                    Color.clear
                        .frame(width: 70, height: 50)
                        .padding(.trailing, 30)
                        .padding(.top, K.topBarHeight)
                        .popover(
                            selection: $step,
                            tag: TutorialStep.done.rawValue,
                            attributes: {
    //                            $0.sourceFrameInset.top = -8
//                                $0.sourceFrameInset.right = 20
                                $0.screenEdgePadding = .init(top: 0, left: 0, bottom: 0, right: -3)
                                $0.position = .absolute(
                                    originAnchor: .bottom,
                                    popoverAnchor: .top
                                )
                                $0.onDismiss = {
                                    didTapDismiss()
                                }
                            }
                        ) {
                            Templates.Container(
                                arrowSide: .top(.mostClockwise),
                                backgroundColor: .accentColor
                            ) {
                                Button {
                                    Haptics.successFeedback()
                                    step = nil
                                    didTapDismiss()
                                } label: {
                                    HStack {
                                        Text(TutorialStep.done.message)
                                            .foregroundColor(.white)
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.white.opacity(0.75))
                                    }
                                }
                            }
                            .frame(maxWidth: 250)
                        }
                }
                Spacer()
            }
            .frame(maxHeight: .infinity)
            
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: appeared)
    }
    
    func appeared() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            step = TutorialStep.edit.rawValue
        }
    }
}

struct TutorialLayerPreview: View {
    var body: some View {
        TutorialLayer {
            
        }
    }
}

struct TutorialLayer_Previews: PreviewProvider {
    static var previews: some View {
        TutorialLayerPreview()
    }
}
