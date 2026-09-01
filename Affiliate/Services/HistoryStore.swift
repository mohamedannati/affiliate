//
//  HistoryStore.swift
//  Affiliate
//
//  Persists URL check history locally on the device.
//

import Foundation

@MainActor
final class HistoryStore: ObservableObject {
    @Published var records: [LinkCheckRecord] = []

    private static let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("url-check-history.json")
    }()

    init() {
        load()
    }

    func add(_ record: LinkCheckRecord) {
        records.insert(record, at: 0)
        if records.count > 50 {
            records = Array(records.prefix(50))
        }
        persist()
    }

    func clear() {
        records.removeAll()
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: Self.fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        records = (try? decoder.decode([LinkCheckRecord].self, from: data)) ?? []
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: Self.fileURL, options: .atomic)
    }
}
