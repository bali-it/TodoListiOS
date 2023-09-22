//
//  customViewModifier.swift
//  CV
//
//  Created by Basel Al Ali on 29.12.22.
//

import SwiftUI

struct CustomViewModifier: ViewModifier {
    var roundedCorns: CGFloat
    var startColor: Color
    var endColor: Color
    var textColor: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(roundedCorns)
            .foregroundColor(textColor)
            .overlay(RoundedRectangle(cornerRadius: roundedCorns).stroke(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2.5))
            .font(.custom("Open Sans", size: 18))
            .shadow(radius: 10)
    }
}
