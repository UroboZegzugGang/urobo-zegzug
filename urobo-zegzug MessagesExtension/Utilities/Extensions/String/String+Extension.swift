import Foundation

extension String {
    func toArray<T>() -> [T]? where T: Decodable {
        let data = Data(self.utf8)
        do {
            let array = try JSONDecoder().decode([T].self, from: data)
            return array
        } catch {
            print("Error converting string to array: \(error)")
            return nil
        }
    }
}
