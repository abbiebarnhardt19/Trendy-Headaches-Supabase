//
//  Tutorial Components.swift
//  Trendy Headaches Supabase
//
//  Created by Abigail Barnhardt on 11/13/25.
//

import SwiftUI

struct TutorialPopup: View {
    var title: String
    var message: String
    var buttonText: String
    var accent: String
    var onNext: () -> Void

    var body: some View {
        ZStack {

            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(buttonText) {
                    print("button works")
                }
                .zIndex(1000)
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color(hex: accent))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}
