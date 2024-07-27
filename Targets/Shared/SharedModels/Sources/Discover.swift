//
//  Discover.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 30.01.24.
//

import Foundation
import JavaScriptCore

public struct Label: Codable, Equatable, Hashable {
    public let text: String
    public let color: String

    public init(text: String, color: String) {
        self.text = text
        self.color = color
    }

    public init?(jsValue: JSValue) {
        guard
            let text = jsValue["text"]?.toString(),
            let color = jsValue["color"]?.toString(),
            Self.isValidHexColor(color)
        else {
            return nil
        }

        self.init(text: text, color: color)
    }

    private static func isValidHexColor(_ color: String) -> Bool {
        let regex = "^#[0-9A-Fa-f]{6}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: color)
    }
}

public struct DiscoverData: Codable, Equatable, Hashable {
    public let url: String
    public let titles: Titles
    public let poster: String
    public let description: String
    public let label: Label
    public let indicator: String
    public let isWidescreen: Bool
    public let current: Int?
    public let total: Int?

    public init(url: String, titles: Titles, description: String, poster: String, label: Label, indicator: String, isWidescreen: Bool = false, current: Int?, total: Int?) {
        self.url = url
        self.titles = titles
        self.description = description
        self.poster = poster
        self.label = label
        self.indicator = indicator
        self.isWidescreen = isWidescreen
        self.current = current
        self.total = total
    }

    public init?(jsValue: JSValue) {
        guard
            let url = jsValue["url"]?.toString(),
            let titles = jsValue["titles"],
            let poster = jsValue["poster"]?.toString(),
            let description = jsValue["description"]?.toString(),
            let label = jsValue["label"],
            let indicator = jsValue["indicator"]?.toString(),
            let titlesValue = Titles(jsValue: titles),
            let labelValue = Label(jsValue: label)
        else {
            return nil
        }

        let isWidescreen = jsValue["isWidescreen"]?.toBool()

        let current = jsValue["current"]?.toInt32()
        let total = jsValue["total"]?.toInt32()

        // let iconText = jsValue["iconText"]?.toString()

        self.url = url
        self.titles = titlesValue
        self.description = description
        self.poster = poster
        self.label = labelValue
        self.indicator = indicator
        self.isWidescreen = isWidescreen ?? false
        // swiftlint:disable force_unwrapping
        self.current = current != nil ? Int(current!) : nil
        self.total = total != nil ? Int(total!) : nil
        // swiftlint:enable force_unwrapping
    }
}

public struct DiscoverSection: Codable, Equatable, Hashable {
    public let title: String
    public let type: Int // 0 = Carousel, 1 = List
    public let list: [DiscoverData]

    public init(title: String, type: Int, list: [DiscoverData]) {
        self.title = title
        self.type = type
        self.list = list
    }

    public init?(jsValue: JSValue) {
        guard
            let title = jsValue["title"]?.toString(),
            let type = jsValue["type"]?.toInt32(),
            let dataList = jsValue["list"]?.toArray()
        else {
            return nil
        }

        var discoverDataList = [DiscoverData]()
        for dataItem in dataList {
            if let dataJSValue = dataItem as? JSValue, let discoverData = DiscoverData(jsValue: dataJSValue) {
                discoverDataList.append(discoverData)
            }
        }

        self.title = title
        self.type = Int(type)
        self.list = discoverDataList
    }

    public static let sampleSection = Self(
        title: "Section",
        type: 0,
        list: [
            DiscoverData(
                url: "",
                titles: Titles(primary: "Primary", secondary: "Secondary"),
                description: """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc semper urna enim, quis
                blandit elit sodales et. Morbi quis tortor a velit ultricies elementum. Morbi auctor
                vitae risus sed fermentum.
                """,
                poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
                label: Label(text: "heart", color: ""),
                indicator: "",
                current: 1,
                total: 12
            )
        ]
    )
}
