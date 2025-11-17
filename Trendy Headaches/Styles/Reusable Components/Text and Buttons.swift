//
//  Custom Text and Buttons.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

//stylized and secure text field
struct CustomTextField: View {
    let bg: String
    let accent: String
    let placeholder: String
    @Binding var text: String
    var width: CGFloat? = 350
    var height: CGFloat? = 50
    var corner: CGFloat? = 25
    var textSize: CGFloat? = 22
    var multiline: Bool = false
    var secure: Bool = false
    var botPad: CGFloat? = 8
    var align: TextAlignment = .leading
    
    // Security parameters
    var maxLength: Int = 1000
    
    var body: some View {
        //different types of text field
        Group {
            if multiline {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(1...2)
            }
            else if secure{
                SecureField(placeholder, text: $text)
            }
            else {
                TextField(placeholder, text: $text)
                    .multilineTextAlignment(align)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 2)
        .frame(width: width ?? UIScreen.main.bounds.width-50, height: height ?? (multiline ? nil : 55))
        .background(Color(hex: accent))
        .foregroundColor(Color(hex: bg))
        .cornerRadius(corner ?? 30)
        .font(.system(size: textSize ?? 22, design: .serif))
        .tint(Color(hex: bg))
        .textContentType(nil)
        .padding(.bottom,  botPad ?? 8)
        //check and restrict values for security
        .onChange(of: text) { oldValue, newValue in
            var filtered = newValue
            
            // Apply max length, cant use giant blocks of text
                filtered = String(filtered.prefix(maxLength))
            
            // Update text if it was filtered
            if filtered != newValue {
                text = filtered
            }
        }
    }
}

//stylized display text
struct CustomText: View {
    var text: String
    var color: String
    var width: CGFloat?
    var textAlign: Alignment? = .leading
    var multiAlign: TextAlignment? = .leading
    var bold: Bool = false
    var textSize: CGFloat? = 22
    
    var body: some View {
        Text(text)
            .font(.system(size: textSize ?? 22, design: .serif))
            .fontWeight(bold ? .bold : .regular)
            .foregroundColor(Color(hex: color))
            .frame(maxWidth: width ?? .infinity, alignment: textAlign ?? .leading)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(multiAlign ?? .center)
    }
}

//custom bullet point list
struct CustomList: View {
    var items: [String]
    var color: String
    
    var body: some View {
        let maxWidth = UIScreen.main.bounds.width / 2 - 40
        
        // estimate width per character and find the widest item
        let charWidth: CGFloat = 12
        let maxItemWidth = items
            .map { CGFloat($0.count + 2) * charWidth }
            .max() ?? (charWidth * 3)
        
        let columnCount = Int(max(1, maxItemWidth / maxWidth))

        //stack text items
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columnCount), spacing: 3) {
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.system(size: 18, design: .serif))
                    .foregroundColor(Color(hex: color))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: maxWidth, alignment: .trailing)
        .padding(.bottom, 15)
        .fixedSize(horizontal: false, vertical: true)
    }
}

//stylized navigation button
struct CustomNavButton<Destination: View>: View {
    var label: String
    var dest: Destination
    var bg: String
    var accent: String
    var width: CGFloat?
    var height: CGFloat? = 55
    var textSize: CGFloat? = 20

    var body: some View {
        NavigationLink {
            dest
        } label: {
            Text(label)
                .frame(width: width ?? 180, height: height ?? 55)
                .background(Color(hex: accent))
                .foregroundColor(Color(hex: bg))
                .cornerRadius(30)
                .font(.system(size: textSize ?? 20, design: .serif))
        }
        .buttonStyle(.plain)
        .padding(.vertical, 7)
    }
}

//"link", small underlined text that brings you somewhere when clicked
struct CustomLink<Destination: View>: View {
    var destination: Destination
    var text: String
    var accent: String
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(text)
                .font(.system(size: 18, design: .serif))
                .foregroundColor(Color(hex: accent))
                .underline(true, color: Color(hex: accent))
                .background(Color.clear)
        }
        .padding(.bottom,15)
        .buttonStyle(.plain)
    }
}

//small red text
struct CustomWarningText: View {
    var text: String
    var body: some View {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        Text(text)
            .foregroundColor(.red)
            .font(.system(size: screenWidth * 0.04, design: .serif))
            .padding(.horizontal, 18)
            .padding(.bottom, 5)
            .frame(width: UIScreen.main.bounds.width-20)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

//stylized button
struct CustomButton: View {
    var text: String? = nil
    var systemImage: String? = nil
    var bg: String
    var accent: String
    var height: CGFloat = 50
    var width: CGFloat = 150
    var corner: CGFloat = 30
    var bold: Bool = false
    var textSize: CGFloat = 20
    var disabled: Bool = false
    var botPad: CGFloat = 10
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: textSize))
            } else if let text = text {
                Text(text)
                    .font(.system(size: textSize, design: .serif))
                    .fontWeight(bold ? .bold : .regular)
            }
        }
        .frame(width: width, height: height)
        .foregroundColor(Color(hex: bg))
        .background(Color(hex: accent))
        .cornerRadius(corner)
        .opacity(disabled ? 0.3 : 1)
        .buttonStyle(.plain)
        .disabled(disabled)
        .padding(.bottom, botPad)
    }
}
