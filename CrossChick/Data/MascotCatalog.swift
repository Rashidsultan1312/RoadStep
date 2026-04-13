import Foundation

enum MascotCatalog {
    static let all: [Mascot] = [
        // free
        Mascot(id: "runner", name: "Runner", imageName: "runner", cost: 0, category: .free),
        Mascot(id: "rooster", name: "Rooster", imageName: "rooster", cost: 0, category: .free),
        Mascot(id: "frog", name: "Frog", imageName: "frog", cost: 0, category: .free),
        // common
        Mascot(id: "cat", name: "Cat", imageName: "cat", cost: 30, category: .common),
        Mascot(id: "bunny", name: "Bunny", imageName: "bunny", cost: 40, category: .common),
        Mascot(id: "hamster", name: "Hamster", imageName: "hamster", cost: 40, category: .common),
        Mascot(id: "skater", name: "Skater", imageName: "skater", cost: 50, category: .common),
        Mascot(id: "bear", name: "Bear", imageName: "bear", cost: 60, category: .common),
        Mascot(id: "turtle", name: "Turtle", imageName: "turtle", cost: 60, category: .common),
        // rare
        Mascot(id: "raccoon", name: "Raccoon", imageName: "raccoon", cost: 100, category: .rare),
        Mascot(id: "fox", name: "Fox", imageName: "fox", cost: 120, category: .rare),
        Mascot(id: "owl", name: "Owl", imageName: "owl", cost: 120, category: .rare),
        Mascot(id: "penguin", name: "Penguin", imageName: "penguin", cost: 150, category: .rare),
        Mascot(id: "ninja", name: "Ninja", imageName: "ninja", cost: 150, category: .rare),
        Mascot(id: "panda", name: "Panda", imageName: "panda", cost: 180, category: .rare),
        Mascot(id: "wolf", name: "Wolf", imageName: "wolf", cost: 200, category: .rare),
        Mascot(id: "monkey", name: "Monkey", imageName: "monkey", cost: 200, category: .rare),
        // legendary
        Mascot(id: "astronaut", name: "Astronaut", imageName: "astronaut", cost: 300, category: .legendary),
        Mascot(id: "dragon", name: "Dragon", imageName: "dragon", cost: 400, category: .legendary),
        Mascot(id: "unicorn", name: "Unicorn", imageName: "unicorn", cost: 500, category: .legendary),
        Mascot(id: "robot", name: "Robot", imageName: "robot", cost: 500, category: .legendary),
    ]

    static func find(_ id: String) -> Mascot? {
        all.first { $0.id == id }
    }
}
