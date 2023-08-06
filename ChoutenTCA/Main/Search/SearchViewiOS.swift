//
//  SearchView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import NavigationTransitions
import ActivityIndicatorView

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct SearchViewiOS: View {
    let store: StoreOf<SearchDomain>
    @StateObject var Colors = DynamicColors.shared
    
    // TEMP
    @State private var scrollPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { proxy in
            WithViewStore(self.store) { viewStore in
                VStack {
                    Group {
                        if viewStore.searchResult.isEmpty {
                            VStack {
                                Text("Nothing to show")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.loading {
                            VStack{
                                ActivityIndicatorView(
                                    isVisible: viewStore.binding(
                                        get: \.loading,
                                        send: SearchDomain.Action.setLoading(newLoading:)
                                    ),
                                    type: .growingArc(
                                        Color(hex: Colors.Primary.dark),
                                        lineWidth: 4
                                    )
                                )
                                .frame(width: 50.0, height: 50.0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(0..<viewStore.searchResult.count) { index in
                                        NavigationLink(
                                            destination: InfoView(
                                                url: viewStore.searchResult[index].url,
                                                store: self.store.scope(
                                                    state: \.infoState,
                                                    action: SearchDomain.Action.info
                                                )
                                            )
                                        ) {
                                            VStack {
                                                if viewStore.searchResult[index].img.contains("https://") {
                                                    KFImage(URL(string: viewStore.searchResult[index].img))
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 110, height: 160)
                                                        .cornerRadius(12)
                                                } else {
                                                    Image(viewStore.searchResult[index].img)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 110, height: 180)
                                                        .frame(minWidth: 110, minHeight: 160)
                                                        .cornerRadius(12)
                                                }
                                                
                                                Text(viewStore.searchResult[index].title)
                                                    .frame(width: 110)
                                                    .lineLimit(1)
                                                
                                                HStack {
                                                    Spacer()
                                                    
                                                    Text("\(viewStore.searchResult[index].currentCount != nil ? String(viewStore.searchResult[index].currentCount!) : "⁓") / \(viewStore.searchResult[index].totalCount != nil ? String(viewStore.searchResult[index].totalCount!) : "⁓")")
                                                        .font(.caption)
                                                }
                                                .frame(width: 110)
                                            }
                                            .frame(maxWidth: 110)
                                        }
                                        .simultaneousGesture(
                                            TapGesture()
                                                .onEnded{ value in
                                                    print(viewStore.searchResult[index].url)
                                                    viewStore.send(.resetInfoData)
                                                }
                                        )
                                    }
                                }
                                .padding(.top, 190)
                                .padding(.bottom, 120)
                                .padding(.horizontal, 20)
                                .background(
                                    GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                                    }
                                )
                                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                    print(value)
                                    withAnimation(.spring(response: 0.3)) {
                                        scrollPosition = value
                                    }
                                }
                            }
                            .coordinateSpace(name: "scroll")
                        }
                    }
                }
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(hex: Colors.Surface.dark))
                .background {
                    if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                        WebView(
                            viewStore: ViewStore(
                                self.store.scope(
                                    state: \.webviewState,
                                    action: SearchDomain.Action.webview
                                )
                            )
                        )
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
                .overlay(alignment: .top) {
                    VStack {
                        if scrollPosition.y > -50 {
                            HStack {
                                Text("Search")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                KFImage(URL(string: "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/2f6ed149-c2f1-45b1-876c-0c26ccf7c2e2/dfw4wvo-a3c9af98-a621-4eeb-bffc-5ead4b300254.png/v1/fill/w_894,h_894,q_70,strp/anime_boy_pfp_by_artificialhub_dfw4wvo-pre.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTAyNCIsInBhdGgiOiJcL2ZcLzJmNmVkMTQ5LWMyZjEtNDViMS04NzZjLTBjMjZjY2Y3YzJlMlwvZGZ3NHd2by1hM2M5YWY5OC1hNjIxLTRlZWItYmZmYy01ZWFkNGIzMDAyNTQucG5nIiwid2lkdGgiOiI8PTEwMjQifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6aW1hZ2Uub3BlcmF0aW9ucyJdfQ.DlYWu-cCoC9x5CawZlOYzbmbZZmYXbnJakAciP5Yug4"))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .cornerRadius(64)
                            }
                            .foregroundColor(Color(hex: Colors.onSurface.dark))
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                
                                ZStack(alignment: .leading) {
                                    if viewStore.query.isEmpty {
                                        Text(viewStore.isDownloadedOnly ? "Search locally..." : "Search for something...")
                                            .opacity(0.7)
                                    }
                                    
                                    TextField(
                                        "",
                                        text: viewStore.binding(
                                            get: \.query,
                                            send: SearchDomain.Action.setQuery(query:)
                                        )
                                    )
                                    .disableAutocorrection(true)
                                    .onSubmit {
                                        if viewStore.isDownloadedOnly {
                                            
                                        } else {
                                            viewStore.send(.resetWebview)
                                        }
                                    }
                                }
                            }
                            .foregroundColor(Color(hex: Colors.onSurface.dark))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background {
                                Color(hex: Colors.SurfaceContainer.dark)
                                    .cornerRadius(10)
                            }
                            
                            if !viewStore.query.isEmpty {
                                Text("Cancel")
                                    .foregroundColor(Color(hex: Colors.onSurface.dark))
                            }
                        }
                        .padding(.top, scrollPosition.y > -50 ? 0 : -12)
                    }
                    .padding(20)
                    .padding(.top, viewStore.isDownloadedOnly ? 0 : proxy.safeAreaInsets.top)
                    .background {
                        Color(hex: Colors.Surface.dark)
                    }
                    .animation(.spring(response: 0.3), value: viewStore.query)
                }
                .ignoresSafeArea()
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct SearchViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        SearchViewiOS(
            store: Store(initialState: SearchDomain.State(), reducer: SearchDomain())
        )
    }
}
