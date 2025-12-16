import Foundation

// result returned by the split calculator
struct SplitResult {
    let perPersonTotals: [UUID: Double]
    let unassignedItems: [String]
}

struct SplitCalculator {
    /// Parse price from a line like "Coffee 3.50" (returns nil if no price found)
    static func parsePrice(from line: String) -> Double? {
        let pattern = #"[0-9]{1,3}(?:[.,][0-9]{2})\b"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let ns = line as NSString
            let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: ns.length))
            if let m = matches.last {
                var s = ns.substring(with: m.range)
                s = s.replacingOccurrences(of: ",", with: ".")
                return Double(s)
            }
        }
        return nil
    }

    /// Compute totals per person given items, people, and assignment map
    static func computeSplit(items: [String], people: [Person], assignments: [String:Set<UUID>]) -> SplitResult {
        var perPerson: [UUID: Double] = [:]
        for p in people { perPerson[p.id] = 0.0 }

        var unassigned: [String] = []

        for item in items {
            guard let price = parsePrice(from: item) else {
                unassigned.append(item)
                continue
            }
            let assigned = assignments[item] ?? Set()
            if assigned.isEmpty {
                unassigned.append(item)
            } else {
                let share = price / Double(assigned.count)
                for pid in assigned {
                    perPerson[pid, default: 0.0] += share
                }
            }
        }
        return SplitResult(perPersonTotals: perPerson, unassignedItems: unassigned)
    }
}

