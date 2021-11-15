//
//  ContentView.swift
//  LabeledPickerExample
//
//  Created by Leo Mehlig on 12.11.21.
//

import SwiftUI
import LabeledPicker

struct ContentView: View {
    
    @State var selected1 = 0
    @State var selected2 = 15
    
    
    
    var body: some View {
        Text("\(selected1) - \(selected2)")
        Button("Reset") {
            self.selected2 = 0
            self.selected1 = 20
        }
        LabeledPicker(
            .value($selected1, size: 30) { Text("\($0)") },
            .label { Text("Test") },
            .value($selected2, size: 30) { Text("\($0)") })
            .background(.red)
            .overlay(
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 2)
                    Spacer()
                }
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
