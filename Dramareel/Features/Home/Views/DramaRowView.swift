import SwiftUI

public struct DramaRowView: View {
    public let title: String
    public var icon: String? = nil
    public let dramas: [Drama]
    public let onSelectDrama: (Drama) -> Void
    public var onSeeAll: (() -> Void)? = nil
    
    public init(
        title: String,
        icon: String? = nil,
        dramas: [Drama],
        onSelectDrama: @escaping (Drama) -> Void,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.dramas = dramas
        self.onSelectDrama = onSelectDrama
        self.onSeeAll = onSeeAll
    }
    
    public var body: some View {
        guard !dramas.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                SectionHeaderView(
                    title: title,
                    icon: icon,
                    showSeeAll: onSeeAll != nil,
                    onSeeAll: onSeeAll
                )
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(dramas) { drama in
                            DramaPosterCard(drama: drama, width: 130, height: 185) {
                                onSelectDrama(drama)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        )
    }
}

public struct GenreFilterBar: View {
    public let categories: [String]
    @Binding var selectedCategory: String
    
    public init(categories: [String], selectedCategory: Binding<String>) {
        self.categories = categories
        self._selectedCategory = selectedCategory
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = category == selectedCategory
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(DramareelTypography.caption(size: 13))
                            .foregroundColor(isSelected ? .white : DramareelColors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                isSelected ?
                                AnyView(DramareelColors.actionGradient) :
                                AnyView(DramareelColors.surfaceCard)
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? Color.white.opacity(0.3) : DramareelColors.surfaceBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
