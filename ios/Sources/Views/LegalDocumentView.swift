import SwiftUI

struct LegalDocumentView: View {
    let title: String
    let body_: String

    var body: some View {
        ScrollView {
            Text(body_)
                .font(.footnote)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LegalDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LegalDocumentView(
                title: "Politique de confidentialité",
                body_: LegalTexts.privacyPolicy(language: .french, contactEmail: SupportConfig.contactEmail)
            )
        }
    }
}
