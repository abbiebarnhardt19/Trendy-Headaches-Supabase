//
//  Custom Form Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//

import SwiftUI

//custom switch
struct CustomToggle: View {
    var color: String
    @Binding var feature: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: color))
            .frame(width: 50, height: 32)
            .overlay(Circle()
                .fill(.white)
                .padding(3)
                .offset(x: feature ? 10 : -10) )
            .onTapGesture { feature.toggle() }
    }
}

//color picker in text field
struct ColorTextField: View {
    var accent: String
    var bg: String
    @Binding var update: String
    var placeholder: String = ""
    var width: CGFloat
    var corner: CGFloat? = 30
    
    @State private var selectedColor: Color = .white
    
    var body: some View {
        CustomTextField(bg: bg, accent: accent, placeholder: placeholder, text: $update, width: width, corner: corner ?? 30)
        .frame(height: 40)
        .overlay(alignment: .trailing) {
            ZStack {
                Image(systemName: "eyedropper")
                    .foregroundColor(Color(hex: bg))
                    .font(.system(size: 17, weight: .bold))
                    .padding(.trailing, 15)
                
                // Transparent but tappable ColorPicker over the same spot
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .labelsHidden()
                    .opacity(0.015)
                    .frame(width: 28, height: 28)
                    .contentShape(Circle())
                    .padding(.trailing, 15)
            }
            .padding(.bottom, 8)
        }
        .onChange(of: selectedColor, initial: false) { oldColor, newColor in
            update = colorToHex(newColor)
        }
        .onAppear {
            selectedColor = Color(hex: update)
        }
    }
    
    //convert color to hex code
    private func colorToHex(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255),  Int(green * 255), Int(blue * 255))
    }
}

//calender dropdown in text field
struct DateTextField: View {
    @Binding var date: Date
    @Binding var textValue: String
    @Binding var bg: String
    @Binding var accent: String
    @State var width: CGFloat = 220
    @State var specialCase: Bool = false
    @State var label: String = "Date:"
    @State var textSize: CGFloat = 22
    @State var iconSize: CGFloat = 25
    @State var bold: Bool = true
    
    @State private var showDatePicker: Bool = false
    @State private var screenWidth = UIScreen.main.bounds.width
    
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                // TextField with button overlay
                HStack{
                    CustomText(text: label, color: accent, bold: bold, textSize: 24)
                        .frame(width: 62, height: 45, alignment: .center)
                    
                    CustomTextField(bg: bg, accent: accent,  placeholder: " ",  text: $textValue,  width: width, textSize: textSize, botPad: 0)
                }
                //put the calendar button over the text field
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { showDatePicker.toggle() } }){
                            Image(systemName: "calendar")
                                .foregroundColor(Color(hex: bg))
                                .font(.system(size: iconSize))
                                .padding(.trailing, 15)
                        }
                    })
                .buttonStyle(PlainButtonStyle())
                
                // Calendar dropdown
                if showDatePicker {
                    DatePicker(" ", selection: $date, in: ...Date(), displayedComponents: .date )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(width: screenWidth * (specialCase ? 0.6 : 0.85),  height: screenWidth * (specialCase ? 0.7: 0.85))
                    .scaleEffect(specialCase ? 0.75 : 1.0)

                    .background(Color(hex: accent))
                    .accentColor(Color(hex: bg))
                    .tint(Color(hex: bg))
                    .cornerRadius(20)
                    .padding()
                    .padding(.bottom, 45)
                    .offset(y: 60)
                    .colorScheme(Color.isHexDark(accent) ? .dark : .light)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onChange(of: date) {
                        textValue = formatter.string(from: date)
                        withAnimation { showDatePicker = false }
                    }
                }
            }
        }
    }
}

//checkbox with label next to it
struct SingleCheckbox: View {
    var text: String
    var color: String
    @Binding var isOn: Bool
    var textSize: CGFloat = 24

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack {
                CustomText(text: text, color: color, bold: true, textSize: textSize)
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: textSize, height: textSize)
                    .foregroundColor(Color(hex: color))
            }
            .padding(.trailing, 30)
            .padding(.bottom, 10)
        }
        .buttonStyle(.plain)
        .frame(width: UIScreen.main.bounds.width - 40)
    }
}

//numerical slider
struct Slider: View {
    @Binding var value: Int64
    let range: ClosedRange<Int64>
    let step: Int
    var color: String
    var width: CGFloat

    private var steps: [Int64] {
        stride(from: range.lowerBound, through: range.upperBound, by: step).map { $0 }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let trackWidth = geo.size.width
                let margin: CGFloat = 14
                let usableWidth = trackWidth - 2 * margin
                let spacing = usableWidth / CGFloat(steps.count - 1)
                let index = steps.firstIndex(of: value) ?? 0

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: color).opacity(0.3))
                        .frame(width: usableWidth + 2 * margin, height: 4)
                        .position(x: trackWidth / 2, y: geo.size.height / 2)

                    Rectangle()
                        .fill(Color(hex: color))
                        .frame(width: CGFloat(index) * spacing, height: 4)
                        .position(x: margin + CGFloat(index) * spacing / 2, y: geo.size.height / 2)

                    ForEach(0..<steps.count, id: \.self) { i in
                        Rectangle()
                            .fill(Color(hex: color))
                            .frame(width: 2, height: 14)
                            .position(x: margin + CGFloat(i) * spacing, y: geo.size.height / 2)
                    }

                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 28, height: 28)
                        .position(x: margin + CGFloat(index) * spacing, y: geo.size.height / 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let clampedX = min(max(gesture.location.x - margin, 0), usableWidth)
                                    let nearestIndex = Int(round(clampedX / spacing))
                                    let safeIndex = min(max(nearestIndex, 0), steps.count - 1)
                                    value = steps[safeIndex]
                                })
                }
            }
            .frame(height: 30)

            HStack(spacing: 0) {
                ForEach(steps, id: \.self) { stepValue in
                    CustomText(text: "\(Int(stepValue))",  color: color, textAlign: .center,  textSize: 18)
                    .frame(width: 35)
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(width: width)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 15)
    }
}

struct MultipleChoice: View {
    @Binding var options: [String]
    @Binding var selected: String?
    var accent: String
    var width: CGFloat

    let circleWidth: CGFloat = 20
    let spacing: CGFloat = 8

    var body: some View {
        let rows = computeRows()
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(rows[rowIndex], id: \.self) { option in
                        HStack(spacing: 8) {
                            Circle()
                                .stroke(Color(hex: accent), lineWidth: 2)
                                .background(Circle()
                                    .fill(selected == option ? Color(hex: accent) : Color.clear))
                                .frame(width: circleWidth, height: circleWidth)
                            
                            CustomText(text: option, color: accent, textSize: 20)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selected = option
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: width, alignment: .leading)
        .padding(.bottom, 10)
        .padding(.leading, 5)
        .onAppear {
            if options.count == 1 {
                selected = options[0]
            }
        }
    }
    
    private func computeRows() -> [[String]] {
        var rows: [[String]] = [[]]
        var currentRowWidth: CGFloat = 0
        let font = UIFont.systemFont(ofSize: 20, weight: .regular)
        let itemSpacing: CGFloat = 12
        
        for option in options {
            let textWidth = option.width(usingFont: font)
            // Circle + gap + text (removed trailing padding from calculation)
            let itemWidth = circleWidth + 8 + textWidth
            
            // Calculate what the new width would be if we add this item
            let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
            
            // Allow going significantly over to pack more items
            if newRowWidth > width * 1.3 && !rows[rows.count - 1].isEmpty {
                // Start a new row
                rows.append([option])
                currentRowWidth = itemWidth
            } else {
                // Add to current row
                rows[rows.count - 1].append(option)
                currentRowWidth = newRowWidth
            }
        }
        
        return rows
    }
}

//dropdown option picker
struct CustomDropdown: View {
    @Binding var theme: String
    @Binding var bg: String
    @Binding var accent: String
    var options: [String]
    var width: CGFloat
    var height: CGFloat
    var corner: CGFloat
    var fontSize: CGFloat
    
    var body: some View {
        Menu {
            Picker(selection: $theme, label: EmptyView()) {
                ForEach(options, id: \.self) { theme in
                    Text(theme)
                        .padding(.leading, 5)
                }
            }
            
        } label: {
            HStack {
                Text(theme)
                    .font(.system(size: fontSize, design: .serif))
                    .padding(.leading, 5)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.trailing, 20)
            }
            .padding(.leading, 10)
            .frame(width: width, height: height, alignment: .leading)
            .background( RoundedRectangle(cornerRadius: corner)
                    .fill(Color(hex: accent)))
            .foregroundColor(Color(hex: bg))
        }
        .onChange(of: theme) {
            let colors = Database.getThemeColors(theme: theme, currentBackground: bg, currentAccent: accent)
            bg = colors.background
            accent = colors.accent
        }
        .buttonStyle(.plain)
        .padding(.bottom, 20)
    }
}
struct MultipleCheckboxWrapped: View {
    @Binding var options: [String]
    @Binding var selected: [String]
    var accent: String
    var bg: String
    var width: CGFloat
    var itemHeight: CGFloat = 20
    var textSize: CGFloat = 14
    
    var body: some View {
        let rows = computeRows()
        
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(rows[rowIndex], id: \.self) { option in
                        HStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: bg), lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(selected.contains(option) ? Color(hex: bg) : Color.clear)
                                    )
                                    .frame(width: itemHeight, height: itemHeight)
                                
                                if selected.contains(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: accent))
                                        .font(.system(size: itemHeight * 0.6, weight: .bold))
                                }
                            }
                            
                            CustomText(
                                text: option,
                                color: bg,
                                textSize: textSize
                            )
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, 4)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if let index = selected.firstIndex(of: option) {
                                    selected.remove(at: index)
                                } else {
                                    selected.append(option)
                                }
                            }
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: width, alignment: .leading)
    }
    
    private func computeRows() -> [[String]] {
        var rows: [[String]] = [[]]
        var currentRowWidth: CGFloat = 0
        let font = UIFont.systemFont(ofSize: textSize, weight: .regular)
        let itemSpacing: CGFloat = 8
        
        for option in options {
            let textWidth = option.width(usingFont: font)
            // Much tighter calculation: Circle + small gap + text only
            let itemWidth = itemHeight + 4 + textWidth
            
            // Calculate what the new width would be if we add this item
            let newRowWidth = currentRowWidth == 0 ? itemWidth : currentRowWidth + itemSpacing + itemWidth
            
            // Allow going significantly over to pack more items
            if newRowWidth > width * 1.3 && !rows[rows.count - 1].isEmpty {
                // Start a new row
                rows.append([option])
                currentRowWidth = itemWidth
            } else {
                // Add to current row
                rows[rows.count - 1].append(option)
                currentRowWidth = newRowWidth
            }
        }
        
        return rows
    }
}
