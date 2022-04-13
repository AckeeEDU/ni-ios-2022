//
//  Widget.swift
//  Widget
//
//  Created by Jakub Olejník on 13.04.2022.
//

import Combine
import Shared
import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    let api = APIService()
    private static var cancellables = Set<AnyCancellable>()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            post1: .init(
                id: "0",
                text: "Text",
                photo: UIImage(),
                postedAt: .init()
            ),
            post2: nil
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(
//            date: Date(),
//            configuration: configuration,
//            text: "Text",
//            photo: UIImage(),
//            postedAt: .init()
//        )
//        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let ud = UserDefaults(suiteName: "group.cz.cvut.fit.Widget")!
        print("[KEY]", ud.bool(forKey: "key"))

        api.feedPublisher().sink { result in
            switch result {
            case .failure:
                completion(Timeline(
                    entries: [SimpleEntry](),
                    policy: .after(Date().addingTimeInterval(10 * 3600)))
                )
            case .finished: break
            }

        } receiveValue: { posts in

            switch context.family {
            case .systemSmall:
                let entries = posts.enumerated().map { index, post -> SimpleEntry in
                    let data = try? Data(contentsOf: post.photos[0])
                    let image = data.flatMap { UIImage(data: $0) }

                    return SimpleEntry(
                        date: .init().addingTimeInterval(Double(index) * 10),
                        configuration: configuration,
                        post1: .init(
                            id: post.id,
                            text: post.text,
                            photo: image,
                            postedAt: post.postedAt
                        ),
                        post2: nil
                    )
                }

                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            case .systemMedium, .systemLarge, .systemExtraLarge:
                let data = try? Data(contentsOf: posts[0].photos[0])
                let image = data.flatMap { UIImage(data: $0) }

                let data2 = try? Data(contentsOf: posts[1].photos[0])
                let image2 = data2.flatMap { UIImage(data: $0) }

                let entry = SimpleEntry(
                    date: .init(),
                    configuration: configuration,
                    post1: .init(
                        id: posts[0].id,
                        text: posts[0].text,
                        photo: image,
                        postedAt: posts[0].postedAt
                    ),
                    post2:.init(
                        id: posts[1].id,
                        text: posts[1].text,
                        photo: image2,
                        postedAt: posts[1].postedAt
                    )
                )

                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }

        }.store(in: &Self.cancellables)

//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    struct Post {
        let id: String
        let text: String
        let photo: UIImage?
        let postedAt: Date
    }

    let date: Date
    let configuration: ConfigurationIntent

    let post1: Post
    let post2: Post?
}

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let post2 = entry.post2 {
            HStack {
                Link(destination: WidgetLink(postID: entry.post1.id).url) {
                    PostView(post: entry.post1)
                }
                Link(destination: WidgetLink(postID: post2.id).url) {
                    PostView(post: post2)
                }
            }
        } else {
            PostView(post: entry.post1)
                .widgetURL(WidgetLink(postID: entry.post1.id).url)
        }
    }
}

struct PostView: View {
    let post: Provider.Entry.Post

    var body: some View {
        ZStack {
            Rectangle().overlay {
                Image(uiImage: post.photo ?? .init())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }

            LinearGradient(
                colors: [.black, .black.opacity(0), .black.opacity(0)],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading) {
                Text(post.text).bold()
                Text(post.postedAt, format: .dateTime).italic()
            }.foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding()
        }
    }
}

@main
struct WidgetApp: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: ConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(entry: SimpleEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                post1: .init(
                    id: "1",
                    text: "Text",
                    photo: UIImage(named: "image2")!,
                    postedAt: .init()
                ),
                post2: nil
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            WidgetEntryView(entry: SimpleEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                post1: .init(
                    id: "1",
                    text: "Text",
                    photo: UIImage(named: "image2")!,
                    postedAt: .init()
                ),
                post2: .init(
                    id: "2",
                    text: "Text",
                    photo: UIImage(named: "image1")!,
                    postedAt: .init()
                )
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
