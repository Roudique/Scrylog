import ScrylogCore

let tool = ScrylogCore()

do {
    try tool.run()
} catch {
    print("Whoops! An error occured: \(error)")
}
