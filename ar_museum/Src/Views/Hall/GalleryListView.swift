import SwiftUI


// 展厅列表视图
struct GalleryListView: View {
    let galleries: [Gallery]
    let onSelect: (Gallery) -> Void
    
    var body: some View {
        List(galleries) { gallery in
            Button(action: { onSelect(gallery) }) {
                HStack {
                    Text(gallery.name)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}