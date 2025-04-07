import SwiftUI

struct ExhibitsListView: View {
    @State private var searchText = ""
    @State private var exhibits = sampleExhibits
    @State private var selectedCategory: String? = nil
    
    var filteredExhibits: [Exhibit] {
        var filtered = exhibits
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return filtered
    }
    
    var categories: [String] {
        Array(Set(exhibits.map { $0.category })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 分类筛选
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CategoryButton(title: "全部", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(title: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 展品列表
                List(filteredExhibits) { exhibit in
                    NavigationLink(destination: ExhibitDetailView(exhibit: exhibit)) {
                        ExhibitRow(exhibit: exhibit)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("展品目录")
            .searchable(text: $searchText, prompt: "搜索展品")
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExhibitRow: View {
    let exhibit: Exhibit
    
    var body: some View {
        HStack {
            Image(exhibit.thumbnailImage)
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(exhibit.name)
                    .font(.headline)
                Text(exhibit.period)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if exhibit.hasARModel {
                Image(systemName: "arkit")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
} 