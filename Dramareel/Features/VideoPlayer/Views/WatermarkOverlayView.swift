import SwiftUI

public struct WatermarkOverlayView: View {
    public let urlString: String
    public let position: String // "top-left", "top-right", "bottom-left", "bottom-right"
    public let opacity: Double
    
    public init(urlString: String, position: String, opacity: Double) {
        self.urlString = urlString
        self.position = position
        self.opacity = opacity
    }
    
    public var body: some View {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack {
                if position.contains("bottom") { Spacer() }
                
                HStack {
                    if position.contains("right") { Spacer() }
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 28)
                            .opacity(opacity)
                    } placeholder: {
                        EmptyView()
                    }
                    .padding(14)
                    
                    if position.contains("left") { Spacer() }
                }
                
                if position.contains("top") { Spacer() }
            }
            .allowsHitTesting(false)
        )
    }
}

public struct SubtitleSelectionSheet: View {
    public let availableSubtitles: [String]
    public let selectedSubtitle: String?
    public let onSelect: (String?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    public init(availableSubtitles: [String], selectedSubtitle: String?, onSelect: @escaping (String?) -> Void) {
        self.availableSubtitles = availableSubtitles
        self.selectedSubtitle = selectedSubtitle
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ZStack {
            DramareelColors.surfaceCard
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Subtitles / Captions")
                        .font(DramareelTypography.sectionTitle(size: 18))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DramareelColors.textMuted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                List {
                    // Off option
                    Button(action: {
                        onSelect(nil)
                        dismiss()
                    }) {
                        HStack {
                            Text("Off")
                                .foregroundColor(.white)
                            Spacer()
                            if selectedSubtitle == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(DramareelColors.electricCyan)
                            }
                        }
                    }
                    .listRowBackground(DramareelColors.surfaceCard)
                    
                    ForEach(availableSubtitles, id: \.self) { subName in
                        Button(action: {
                            onSelect(subName)
                            dismiss()
                        }) {
                            HStack {
                                Text(subName)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedSubtitle == subName {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DramareelColors.electricCyan)
                                }
                            }
                        }
                        .listRowBackground(DramareelColors.surfaceCard)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .presentationDetents([.height(280)])
    }
}
