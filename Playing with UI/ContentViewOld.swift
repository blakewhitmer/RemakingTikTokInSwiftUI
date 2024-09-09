//
//  ContentView.swift
//  Playing with UI
//
//  Created by Blake Whitmer on 6/3/24.
//

import SwiftUI

struct ContentViewOld: View {
    var height = UIScreen.main.bounds.height
    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.green)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * -0.5)
                .edgesIgnoringSafeArea(.all)
                .offset(y: offset.height)
            Rectangle()
                .foregroundStyle(Color.black)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .offset(y: offset.height)
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                HStack {
                    Spacer()
                    
                    Text("\(-UIScreen.main.bounds.height)")
                    
                        .offset(y: offset.height)
                        
                    Spacer()
                }
                
                
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    print(offset)
                }
                .onEnded { gesture in
                    offset = .zero
                }
        )
    }
}

#Preview {
    ContentView()
}
