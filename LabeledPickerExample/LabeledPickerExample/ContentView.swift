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
            .value(.constant(9), size: 24, content: { Text("\($0)") }),
            .value(.constant(41), size: 60, content: { Text("\($0)") }),
            .value(.constant(1), size: 3, content: {  value in
                Group {
                    switch value {
                    case 0:
                        Text("-1")
                    case 2:
                        Text("+1")
                    default:
                        EmptyView()
                    }
                }
                .font(.footnote.bold())
                .aligned(to: .leading)
            }),
            .label { Image(systemName: "arrow.right") },
            
                .value(.constant(9), size: 24, content: { Text("\($0)") }),
            .value(.constant(41), size: 60, content: { Text("\($0)") }),
            .value(.constant(1), size: 6, content: {  value in
                Group {
                    switch value {
                    case 0:
                        Text("AM\u{207B}\u{00B9}")
                    case 1:
                        Text("PM\u{207B}\u{00B9}")
                    case 2:
                        Text("AM")
                    case 3:
                        Text("PM")
                    case 4:
                        Text("AM\u{207A}\u{00B9}")
                    case 5:
                        Text("PM\u{207A}\u{00B9}")
                    default:
                        EmptyView()
                    }
                }
                .font(.footnote.bold())
                .aligned(to: .leading)
            })
        )
            .font(.title3)
        
        LabeledPicker(
            .value(.constant(9 + 24), size: 24*3, content: { value in
                Group {
                    switch value {
                    case 0...23:
                        Text("\(value)\u{207B}\u{00B9}")
                    case 24...47:
                        Text("\(value - 24)")
                    default:
                        Text("\(value - 48)\u{207A}\u{00B9}")
                    }
                }
            }),
            .value(.constant(41), size: 60, content: { Text("\($0)") }),
            .value(.constant(1), size: 2, content: {  value in
                Group {
                    switch value {
                    case 0:
                        Text("AM")
                    case 1:
                        Text("PM")
                    default:
                        EmptyView()
                    }
                }
                .font(.footnote.bold())
                .aligned(to: .leading)
            }),
            .label { Image(systemName: "arrow.right") },
            
                .value(.constant(9 + 24), size: 24*3, content: { value in
                    Group {
                        switch value {
                        case 0...23:
                            Text("\(value)\u{207B}\u{00B9}")
                        case 24...47:
                            Text("\(value - 24)")
                        default:
                            Text("\(value - 48)\u{207A}\u{00B9}")
                        }
                    }
                }),
            .value(.constant(41), size: 60, content: { Text("\($0)") }),
            .value(.constant(1), size: 2, content: {  value in
                Group {
                    switch value {
                    case 0:
                        Text("AM")
                    case 1:
                        Text("PM")
                    default:
                        EmptyView()
                    }
                }
                .font(.footnote.bold())
                .aligned(to: .leading)
            })
            
        )
            .font(.title3)
        
        //        LabeledPicker(
        //            .value(.constant(1), size: 24, content: {
        //                Text("\($0)").font(.title3)
        //                    .aligned(to: .trailing)
        //            }),
        //            .label {
        //                Text("hours").font(.headline)
        //                    .aligned(to: .leading)
        //            },
        //            .value(.constant(30), size: 60, content: {
        //                Text("\($0)").font(.title3)
        //                    .aligned(to: .trailing)
        //            }),
        //            .label {
        //                Text("min").font(.headline)
        //                    .aligned(to: .leading)
        //            }
        //        )
        //        LabeledPicker(
        //            .value($selected1, size: 30) { Text("\($0)") },
        //            .label { Text("Test") },
        //            .value($selected2, size: 30) { Text("\($0)") })
        //            .background(.red)
        //            .overlay(
        //                VStack {
        //                    Spacer()
        //                    Rectangle()
        //                        .frame(height: 2)
        //                    Spacer()
        //                }
        //            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AlignmentModifier: ViewModifier {
    let edges: Edge.Set
    
    func body(content: Content) -> some View {
        VStack {
            if self.edges.contains(.bottom) {
                Spacer(minLength: 0)
            }
            HStack {
                if self.edges.contains(.trailing) {
                    Spacer(minLength: 0)
                }
                content
                    .multilineTextAlignment(self.edges.textAlignment)
                
                if self.edges.contains(.leading) {
                    Spacer(minLength: 0)
                }
            }
            if self.edges.contains(.top) {
                Spacer(minLength: 0)
            }
        }
    }
}

extension Edge.Set {
    var textAlignment: TextAlignment {
        if self.contains(.leading), !self.contains(.trailing) {
            return .leading
        } else if self.contains(.trailing), !self.contains(.leading) {
            return .trailing
        } else {
            return .center
        }
    }
}

extension TextAlignment {
    var edges: Edge.Set {
        switch self {
        case .leading:
            return .leading
        case .center:
            return .horizontal
        case .trailing:
            return .trailing
        }
    }
}

public extension View {
    func aligned(to edges: Edge.Set) -> some View {
        ModifiedContent(content: self, modifier: AlignmentModifier(edges: edges))
    }
    
    func alignment(_ alignment: TextAlignment) -> some View {
        ModifiedContent(content: self, modifier: AlignmentModifier(edges: alignment.edges))
    }
}
