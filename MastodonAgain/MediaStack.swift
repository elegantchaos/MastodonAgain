import SwiftUI
import Mastodon
import AVKit
import CachedAsyncImage

struct MediaStack: View {
    let attachments: [MediaAttachment]

    var body: some View {
        HStack {
            ForEach(attachments) { attachment in
                switch attachment.type {
                case .image, .gifv:
                    ImageAttachmentView(attachment: attachment)
                case .video:
                    VideoPlayer(player: AVPlayer(url: attachment.url))
                case .audio:
                    VideoPlayer(player: AVPlayer(url: attachment.url))
                case .unknown:
                    Text("Unknown attachment")
                }
            }
        }
        .frame(maxHeight: 180)
    }
}

struct ImageAttachmentView: View {
    let attachment: MediaAttachment

    var body: some View {
        if let url = attachment.previewURL, let smallSize = attachment.meta?.small?.cgSize {
            ContentImage(url: url, size: smallSize, blurhash: attachment.blurHash, accessibilityLabel: Text("TODO"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        else {
            Text("NO PREVIEW OR NO SIZE").debuggingInfo()
        }
    }
}

struct ContentImage: View {
    let url: URL
    let size: CGSize?
    let blurhash: Blurhash?
    let sensitive: Bool
    let accessibilityLabel: Text?

    @State
    var hover = false

    init(url: URL, size: CGSize? = nil, blurhash: Blurhash? = nil, sensitive: Bool = false, accessibilityLabel: Text? = nil) {
        self.url = url
        self.size = size
        self.blurhash = blurhash
        self.sensitive = sensitive
        self.accessibilityLabel = accessibilityLabel
    }

    var body: some View {
        image
    }

    var image: some View {
        CachedAsyncImage(url: url) { image in
            image.resizable().scaledToFit()
        }
        placeholder: {
            if let blurhash, let size {
                blurhash.image(size: size)
            }
            else {
                LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        .onHover { value in
            hover = value
        }
        .redlined(hover)
        .overlay() {
            if hover {
                VStack {
                    Text("\(url, format: .url)").lineLimit(1)
                    if let size {
                        Text("\(size.width, format: .number), \(size.height, format: .number)")
                    }
                }
                .font(.caption2)
                .padding()
                .background(Capsule().fill(Color.white))
            }
        }
    }
}
