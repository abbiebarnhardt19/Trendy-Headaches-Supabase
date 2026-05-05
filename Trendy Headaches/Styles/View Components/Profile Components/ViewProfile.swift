//
//  EditingView.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/15/25.
//

import SwiftUI
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients([recipient])
        mail.setSubject(subject)
        mail.setMessageBody(body, isHTML: false)
        return mail
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            dismiss()
        }
    }
}

struct NoMailView: View {
    @Binding var showReportIssue: Bool
    @Binding var bg: String
    @Binding var accent: String
    
    var body: some View {
        ZStack {
            // Full screen background

            Color(hex: bg)
                .ignoresSafeArea()
            
            WavyTopBottomRectangle(waves: 7, amp: 12, accent: accent, x: 0, y: -UIScreen.main.bounds.height * 0.475, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.35)
                    .zIndex(5)
                WavyTopBottomRectangle(waves: 7, amp: 8, accent: accent, x: 0, y: UIScreen.main.bounds.height * 0.395, width: UIScreen.main.bounds.width, height: 80)
                    .zIndex(1)
            
            VStack(spacing: 30) {
                CustomText(text: "Whoops!", color:accent, textAlign: .center, textSize: 40)
                CustomText(text: "Looks like you don't have a mail account set up in your system settings. You can set up an account there, or you can email us at trendyheadachesdeveloper@gmail.com", color: accent, textAlign: .center, multiAlign: .center, textSize: 20)
                
                CustomButton(text: "Close", bg: bg, accent: accent) {
                    showReportIssue = false
                }
            }
            .padding()
        }
    }
}

struct ViewProfile: View {
    let screenWidth: CGFloat
    
    @Binding var symps: [String]
    @Binding var prevMeds: [String]
    @Binding var triggs: [String]
    @Binding var emergMeds: [String]
    @Binding var newSQ: String
    @Binding var themeName: String
    @Binding var accent: String
    @Binding var newAcc: String
    @Binding var newBG: String
    
    @Binding var isEditing: Bool
    //@Binding var showLogView: Bool
    @Binding var showReportIssue: Bool
    @Binding var logOut: Bool
    @Binding var showDelete: Bool
    
    
    let buttonNames: [String]
    @EnvironmentObject var tutorialManager: TutorialManager
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        let colWidth = screenWidth / 2 - 20
        
        VStack {
            CustomText(text: "User Profile", color: newAcc, textAlign: .center, textSize: 45)
                .padding(.vertical, 50)
            
            HStack(alignment: .top) {
                VStack {
                    SectionList(colTitle: "Symptoms", items: symps, width: colWidth, color: accent)
                    SectionList(colTitle: "Preventative Treatments", items: prevMeds, width: colWidth, color: accent)
                    SectionList(colTitle: "Security Question", items: [newSQ], width: colWidth, color: accent)
                }
                .frame(maxWidth: colWidth)
                
                VStack {
                    SectionList(colTitle: "Triggers", items: triggs, width: colWidth, color: accent)
                    SectionList(colTitle: "Emergency Treatments", items: emergMeds, width: colWidth, color: accent)
                    SectionList(colTitle: "Color Theme", items: [themeName], width: colWidth, color: accent)
                    
                    HStack {
                        Spacer()
                        let buttonActions: [() -> Void] = [
                            { isEditing = true },
                            { showReportIssue = true},
                            { userSession.logout(); logOut = true },
                            { showDelete = true }
                        ]
                        
                        FloatButton(accent: newAcc, bg: newBG, options: buttonNames, actions: buttonActions)
                            .padding(.top, 20)
                    }
                    .padding(.trailing, 10)
                }
                .frame(maxWidth: colWidth)
                .sheet(isPresented: $showReportIssue) {
                    if MFMailComposeViewController.canSendMail() {
                        MailComposeView(
                            recipient: "support@yourapp.com",
                            subject: "Bug Report",
                            body: """
                            Please describe the issue:
                            
                            
                            ---
                            App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                            Device: \(UIDevice.current.model)
                            iOS: \(UIDevice.current.systemVersion)
                            """
                        )
                    } else {
                        NoMailView(showReportIssue: $showReportIssue,
                                   bg: $newBG, accent: $newAcc)
                        .presentationDetents([.fraction(0.85)])
                    }
                }
                
            }
        }
    }
}
