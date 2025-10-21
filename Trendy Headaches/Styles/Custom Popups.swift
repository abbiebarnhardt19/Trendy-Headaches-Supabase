//
//  Popups.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/2/25.
//
import SwiftUI

struct PolicyTextView: View {
    var policyFileName: String
    var textColor: Color

    private var lines: [String] {
        guard let url = Bundle.main.url(forResource: policyFileName, withExtension: "txt"),
              let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return ["Could not load policy."]
        }
        return contents
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(lines, id: \.self) { line in
                Group {
                    switch true {
                    case line.starts(with: "##"):
                        Text(line.replacingOccurrences(of: "##", with: "")).font(.headline).bold()
                    case line.starts(with: "#"):
                        Text(line.replacingOccurrences(of: "#", with: "")).font(.title2).bold()
                    case line.starts(with: "•"), line.starts(with: "-"):
                        Text(line).font(.body).padding(.leading, 20)
                    case line.trimmingCharacters(in: .whitespaces).isEmpty:
                        Spacer().frame(height: 8)
                    default:
                        Text(line).font(.body)
                    }
                }
            }
        }
        .foregroundColor(textColor)
        .padding()
    }
}

struct PolicySheetView: View {
    @Environment(\.dismiss) private var dismiss
    var policyFileName: String
    var showsAgreeButton: Bool
    var onAgree: (() -> Void)?

    private let backgroundColor = Color(hex: "#001d00")
    private let textColor = Color(hex: "#b5c4b9")
    private let textHex = "#b5c4b9"

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                CustomText( text: "Data Policy",  color: textHex, width: 300, textAlign: .center, textSize: 50)
                PolicyTextView(policyFileName: policyFileName, textColor: textColor)
            }
            .background(backgroundColor.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agree") { dismiss(); onAgree?() }
                        .opacity(showsAgreeButton ? 1 : 0)
                        .disabled(!showsAgreeButton)
                }
            }
        }
    }
}

struct EmergencyMedPopup: View {
    @Binding var selectedAnswer: Bool?
    @Binding var isPresented: Bool
    var oldLogID: Int64
    var background: String = ""
    var accent: String = ""

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let yesNoOptions = ["Yes", "No"]

        guard let logDetails = Database.shared.getLogDetails(logID: oldLogID) else {
            return AnyView(Text("Log not found"))
        }
        
        let date = logDetails.date
        let symptomName = logDetails.symptomName
        let emergencyMedName = logDetails.emergencyMedName

        return AnyView(
            ZStack {
                VStack(spacing: 15) {
                    HStack {
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: background))
                                .font(.system(size: 25))
                        }
                        .frame(width: 10, height: 10)
                        .padding(.trailing, 10)
                    }
                    .frame(width: screenWidth * 0.75)
                    
                    // Title
                    CustomText(
                        text: "Did \(emergencyMedName) help with your \(symptomName) on \(formatter.string(from: date))?", color: background, width: screenWidth * 0.75, textAlign: .center, multiAlign: .center, textSize: 20)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    
                    // Multiple Choice
                    HStack {
                        Spacer()
                        VStack {
                            MultipleChoice(options: .constant(yesNoOptions),  selected: Binding(get: {
                                        if let answer = selectedAnswer {
                                            return answer ? "Yes" : "No"
                                        }
                                        return ""
                                    },
                                    set: { newValue in
                                        selectedAnswer = (newValue == "Yes")
                            }), accent: background, width: screenWidth - 100 )
                        }
                        .frame(width: 100)
                        Spacer()
                    }
                    
                    // Submit Button
                    CustomButton(text: "Update Log", bg: accent, accent: background, height: 40, width: 150, bold: true, textSize: 16,
                                 action: {
                                    if let answer = selectedAnswer {
                                        Database.shared.updateMedEffective(logID: oldLogID, medEffectiveValue: answer )}
                                    isPresented = false})
                    .disabled(selectedAnswer == nil)
                    .opacity(selectedAnswer == nil ? 0.5 : 1)
                }
                .padding(.vertical, 20)
                .overlay(RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(hex: background), lineWidth: 3) )
                .frame(width: screenWidth * 0.85)
                .background(Color(hex: accent))
                .cornerRadius(30)
            }
        )
    }
}
