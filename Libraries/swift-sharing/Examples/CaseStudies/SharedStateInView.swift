import Sharing
import SwiftUI

struct SharedStateInView: SwiftUICaseStudy {
  let caseStudyTitle = "Shared state in SwiftUI view"
  let caseStudyNavigationTitle = "In SwiftUI"
  let readMe = """
    Demonstrates how to use a `@Shared` value directly in a SwiftUI view.
    """

  @Shared(.appStorage("count")) var count = 0

  var body: some View {
    Text("\(count)")
    Button("Decrement") {
      $count.withLock { $0 -= 1 }
    }
    Button("Increment") {
      $count.withLock { $0 += 1 }
    }
  }
}

#Preview {
  NavigationStack {
    CaseStudyView {
      SharedStateInView()
    }
  }
}
