//
//  Custom bg Components.swift
//  Trendy Headaches
//
//  Created by Abigail Barnhardt on 10/10/25.
//

import SwiftUI

struct AnalyticsBGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        Color(hex: bg).ignoresSafeArea()

        SameAmplitudeBlob(waves: 10, amp: 20, accent: accent,  x: UIScreen.main.bounds.height * 0.425, y: -UIScreen.main.bounds.width * 0.32, rotation:295, width: UIScreen.main.bounds.width)
            .zIndex(5)
        SameAmplitudeBlob(waves: 10, amp: 20, accent: accent,  x: UIScreen.main.bounds.height * 0.29, y: -UIScreen.main.bounds.width * 0.3, rotation:117, width: UIScreen.main.bounds.width)
            .zIndex(5)
    }
}

struct ListBGComps: View {
    var bg: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            
            SameAmplitudeBlob(waves: 6, amp: 15, accent: accent, x: -UIScreen.main.bounds.width * 0.1, y: -UIScreen.main.bounds.height * 0.47, rotation: 0, width:UIScreen.main.bounds.width+70, height:UIScreen.main.bounds.height*0.15)
            
            SameAmplitudeBlob(waves: 6, amp: 15, accent: accent, x: -UIScreen.main.bounds.width * 0.08, y: -UIScreen.main.bounds.height * 0.335, rotation: 180, width:UIScreen.main.bounds.width+70, height:UIScreen.main.bounds.height*0.125)
        }
    }
}

struct LogBGComps: View {
    var bg: String
    var accent: String
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        Color(hex: bg).ignoresSafeArea()
        WavyTopBottomRectangle(waves: 7, amp: 10, accent: accent, x: 0, y: -UIScreen.main.bounds.height * 0.64, width: screenWidth, height: UIScreen.main.bounds.height * 0.35)
                .zIndex(5)
            WavyTopBottomRectangle(waves: 7, amp: 8, accent: accent, x: 0, y: UIScreen.main.bounds.height * 0.41, width: screenWidth, height: 80)
                .zIndex(1)
    }
}

struct ProfileBGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            WavyTopBottomRectangle(waves: 7, amp: 10, accent: accent, x: 0, y: -UIScreen.main.bounds.height * 0.625, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.35)
                    .zIndex(5)
                WavyTopBottomRectangle(waves: 7, amp: 8, accent: accent, x: 0, y: UIScreen.main.bounds.height * 0.395, width: UIScreen.main.bounds.width, height: 80)
                    .zIndex(1)
        }
    }
}

struct Create1BGComps: View {
    var bg: String
    var accent: String
    var fixedHeight: CGFloat

    let width = UIScreen.main.bounds.width
    

    var body: some View {
        
        let contentHeight = (width * 0.125) + 5 * (width*0.55 + fixedHeight * 0.6) + (fixedHeight * 0.015) * 5 + fixedHeight * 0.06
        
        let blobHeight = max((fixedHeight - contentHeight)/2, fixedHeight * 0.1)
        
        ZStack {
            
            // Top blob
            WavyTopBottomRectangle(waves: 6, amp: 8, accent: accent, x: 0, y: -fixedHeight/2 + blobHeight/2 - fixedHeight * 0.1, width: width, height: blobHeight)
                .zIndex(5)
            
            // Bottom blob
            WavyTopBottomRectangle(waves: 6, amp: 8, accent: accent, x: 0, y: fixedHeight/2 - blobHeight/2  + fixedHeight * 0.08, width: width, height: blobHeight)
                .zIndex(5)
        }
    }
}

struct Create2BGComps: View {
    var bg: String
    var accent: String
    
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: width * 0.3, y: -height * 0.25, rotation: -180)
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: width * 0.3, y: -height * 0.25, rotation: 360)
        }
    }
}

struct Create3BGComps: View {
    var bg: String
    var accent: String
    
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height

    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: bg).ignoresSafeArea()
                .zIndex(-1)
            WavyTopBottomRectangle(waves: 6, amp: 8, accent: accent, x: 0, y: height * 0.85, width: width, height: height * 0.2)
                .zIndex(5)
            WavyTopBottomRectangle(waves: 6, amp: 8, accent: accent, x: 0, y: -height * 0.18, width: width, height: height * 0.2)
                .zIndex(5)
        }
    }
}


struct Forgot1BGComps: View {
    var bg: String
    var accent: String

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 140, y: -200, rotation: 110)
            SameAmplitudeBlob(waves: 10, amp: 20, accent: accent, x: 280, y: -120, rotation: 290)
        }
    }
}

struct Forgot2BGComps: View {
    var bg: String
    var accent: String
    
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 5, amp: 20, accent: accent, x: 0, y: -height * 0.425, rotation: 0, width: width, height: height * 0.35)
            SameAmplitudeBlob(waves: 5, amp: 16, accent: accent, x: 0, y: -height * 0.4, rotation: 180, width: width, height: height * 0.25)
        }
    }
}

struct Forgot3BGComps: View {
    var bg: String
    var accent: String
    
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 5, amp: 30, accent: accent, x: height * 0.39, y: 0, rotation: 270, width: height * 0.25, height: width)
            SameAmplitudeBlob(waves: 5, amp: 30, accent: accent, x: height * 0.39, y: 0, rotation: 90, width: height * 0.25, height: width)
        }
    }
}

struct InitialViewBGComps: View {
    var bg: String
    var accent: String
    
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 5, amp: 25, accent: accent, x: height * 0.4, y: 0, rotation: 90, width: 200, height: width)
            SameAmplitudeBlob(waves: 5, amp: 25, accent: accent, x: height * 0.4, y: 0, rotation: 270, width: 200, height: width)
        }
    }
}

struct LoginBGComps: View {
    var bg: String
    var accent: String
    
    @State var width = UIScreen.main.bounds.width
    @State var height = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            Color(hex: bg).ignoresSafeArea()
            SameAmplitudeBlob(waves: 4, amp: 20, accent: accent, x: 0, y:  -height * 0.425, rotation: 0, width:width, height:height * 0.25)
            SameAmplitudeBlob(waves: 5, amp: 16, accent: accent, x: 0, y: -height * 0.375, rotation: 180, width:width, height:height * 0.25)
        }
    }
}
