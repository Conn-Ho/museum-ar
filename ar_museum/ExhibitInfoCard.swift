import SwiftUI

struct ExhibitInfoCard: View {
    let exhibit: Exhibit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exhibit.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(exhibit.period)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(exhibit.description)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(3)
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(10)
    }
} 