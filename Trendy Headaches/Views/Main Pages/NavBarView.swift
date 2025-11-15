//
//  NavBarView.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 8/31/25.
//

import SwiftUI

struct NavBarView: View {
    let userID: Int64
    @Binding var bg: String
    @Binding var accent: String
    @Binding var selected: Int?
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    struct NavItem {
        let icon: String
        let label: String
        let destination: AnyView
        let padding: EdgeInsets?
    }
    
    var navItems: [NavItem] {
        [NavItem(icon: "square.and.pencil", label: "Log",
                    destination: AnyView(LogView(userID: userID).navigationBarBackButtonHidden(true)),
                    padding: EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0)),
            
//            NavItem(icon: "list.bullet", label: "List",
//                    destination: AnyView(ListView(userID: userID, bg: $bg, accent: $accent).navigationBarBackButtonHidden(true)),
//                    padding: EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0)),
         
         NavItem(icon: "list.bullet", label: "List", destination: AnyView(ListView(userID: userID).navigationBarBackButtonHidden(true)),padding: EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 0)),
            
            NavItem(icon: "chart.bar.xaxis", label: "Analytics",
                    destination: AnyView(AnalyticsView(userID: userID, bg: $bg, accent: $accent).navigationBarBackButtonHidden(true)),
                    padding: nil),
        
        NavItem(icon: "person.fill", label: "Profile",
                destination: AnyView(ProfileView(userID: userID).navigationBarBackButtonHidden(true)),
                padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15)) ]
    }
    
    var body: some View {
        ZStack {
            Color(hex: bg)
            HStack {
                ForEach(navItems.indices, id: \.self) { index in
                    let item = navItems[index]
                    Spacer()
                    NavigationLink(destination: item.destination) {
                        VStack(spacing: 2) {
                            Image(systemName: item.icon)
                                .font(.system(size: width * 0.04))
                            CustomText(text: item.label, color: accent, textAlign: .center, multiAlign: .center, textSize: 15)
                        }
                        .frame(width: width/5, height: height * 0.1)
                        .background(
                            ZStack {
                                if selected == index {
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(Color(hex: accent).opacity(0.075))
                                        .blur(radius: 8)
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(Color(hex: accent).opacity(0.0375))
                                        .blur(radius: 16)
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(Color(hex: accent).opacity(0.01))
                                        .blur(radius: 45)
                                }
                            } )
                        .animation(.easeInOut(duration: 0.0), value: selected)
                    }
                    .buttonStyle(.plain)

                }
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width)
            .foregroundColor(Color(hex: accent))
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .frame(height: height * 0.075)
        .ignoresSafeArea(edges: .bottom)
        .zIndex(1)
    }
}
