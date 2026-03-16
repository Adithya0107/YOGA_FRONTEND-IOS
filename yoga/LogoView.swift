//
//  LogoView.swift
//  yoga
//
//  Created by Aditya on 25/02/26.
//
import SwiftUI

struct LogoView: View {
    var isLarge: Bool = true
    
    var body: some View {
        VStack(spacing: 24) {
            
            Image("Image")
                .resizable()
                .scaledToFit()
                .frame(width: isLarge ? 300 : 140)
            
          
        }
    }
}
