import SwiftUI

struct ExhibitPickerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedExhibit: Exhibit?
    
    let exhibits = sampleExhibits.filter { $0.hasARModel }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                HStack {
                    Text("选择展品")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(exhibits) { exhibit in
                            ExhibitPickerItem(exhibit: exhibit)
                                .onTapGesture {
                                    selectedExhibit = exhibit
                                    isPresented = false
                                }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.gray.opacity(0.9))
            .cornerRadius(16)
            .padding()
        }
    }
}

struct ExhibitPickerItem: View {
    let exhibit: Exhibit
    
    var body: some View {
        VStack {
            Image(exhibit.thumbnailImage)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .cornerRadius(8)
            
            Text(exhibit.name)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
    }
} 