import ScrylogCore

let tool = ScrylogCore()

do {
    if #available(OSX 10.12, *) {
        try tool.run()
    } else {
        print("Sorry, this script is not supported on Linux :(")
    }
} catch {
    print("Whoops! An error occured: \(error)")
}
