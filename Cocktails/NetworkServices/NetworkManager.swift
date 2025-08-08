import Foundation

class CocktailService {
    static let shared = CocktailService()
    private let baseURL = "https://api.api-ninjas.com/v1/cocktail"
    private let apiKey = "GgWNzcspl4VcCHgTVjcRJw==lQXt8em2nWrVxH1s"

    func searchCocktail(name: String, completion: @escaping (Result<[Cocktail], Error>) -> Void) {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: baseURL + "?name=" + encodedName!)!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let cocktails = try JSONDecoder().decode([Cocktail].self, from: data)
                completion(.success(cocktails))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func getRandomCocktail(completion: @escaping (Result<[Cocktail], Error>) -> Void) {
        let randomNames = ["margarita", "mojito", "cosmopolitan", "martini", "manhattan", "daiquiri", "whiskey sour", "pina colada", "bloody mary", "old fashioned"]
        let randomName = randomNames.randomElement()!
        searchCocktail(name: randomName, completion: completion)
    }
}
