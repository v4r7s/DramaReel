import SwiftUI

public struct DramaSearchView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    public let onSelectDrama: (Drama) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init(viewModel: HomeViewModel, onSelectDrama: @escaping (Drama) -> Void) {
        self.viewModel = viewModel
        self.onSelectDrama = onSelectDrama
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                DramareelColors.backgroundDark
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DramareelColors.neonPink)
                        TextField("Search titles, genres, actors...", text: $viewModel.searchQuery)
                            .foregroundColor(.white)
                            .onChange(of: viewModel.searchQuery) { _ in
                                viewModel.performSearch()
                            }
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: {
                                viewModel.searchQuery = ""
                                viewModel.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(DramareelColors.textMuted)
                            }
                        }
                    }
                    .padding(12)
                    .background(DramareelColors.surfaceCard)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(DramareelColors.surfaceBorder, lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    if viewModel.searchQuery.isEmpty {
                        // Empty prompt
                        VStack(spacing: 12) {
                            Spacer()
                            Image(systemName: "film.stack")
                                .font(.system(size: 40))
                                .foregroundColor(DramareelColors.textMuted)
                            Text("Search Dramareel")
                                .font(DramareelTypography.sectionTitle(size: 16))
                                .foregroundColor(DramareelColors.textPrimary)
                            Text("Find thousands of episodes, trending short dramas, and new releases.")
                                .font(DramareelTypography.body(size: 13))
                                .foregroundColor(DramareelColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Spacer()
                        }
                    } else if viewModel.searchResults.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No Results Found",
                            message: "We couldn't find any drama matching \"\(viewModel.searchQuery)\". Try another title or genre."
                        )
                    } else {
                        // Results Grid
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.searchResults) { drama in
                                    DramaPosterCard(drama: drama, width: 110, height: 160) {
                                        dismiss()
                                        onSelectDrama(drama)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(DramareelColors.electricCyan)
                }
            }
        }
    }
}
