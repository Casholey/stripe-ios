//
//  ConsentBodyView.swift
//  StripeFinancialConnections
//
//  Created by Krisjanis Gaidis on 6/15/22.
//

import Foundation
import UIKit
@_spi(STP) import StripeCore
@_spi(STP) import StripeUICore

@available(iOSApplicationExtension, unavailable)
class ConsentBodyView: UIView {
    
    private let bulletItems: [FinancialConnectionsConsent.Body.BulletItem]
    
    init(
        bulletItems: [FinancialConnectionsConsent.Body.BulletItem],
        didSelectURL: @escaping (URL) -> Void
    ) {
        self.bulletItems = bulletItems
        super.init(frame: .zero)
        backgroundColor = .customBackgroundColor
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 16
        bulletItems.forEach { bulletItem in
            verticalStackView.addArrangedSubview(
                CreateLabelView(
                    text: bulletItem.content,
                    action: didSelectURL
                )
            )
        }
        addAndPinSubview(verticalStackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOSApplicationExtension, unavailable)
private func CreateLabelView(text: String, action: @escaping (URL) -> Void) -> UIView {
    let imageView = UIImageView(image: Image.close.makeImage(template: false))
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: 16),
        // skip `imageView.heightAnchor` so the labels naturally expand
    ])
    
    let label = ClickableLabel(
        font: UIFont.stripeFont(forTextStyle: .detail),
        boldFont: UIFont.stripeFont(forTextStyle: .detailEmphasized),
        linkFont: UIFont.stripeFont(forTextStyle: .detailEmphasized),
        textColor: .textSecondary
    )
    label.setText(text, action: action)

    let horizontalStackView = UIStackView(
        arrangedSubviews: [
            imageView,
            label,
        ]
    )
    horizontalStackView.axis = .horizontal
    horizontalStackView.spacing = 10
    horizontalStackView.alignment = .top
    return horizontalStackView
}

#if DEBUG

import SwiftUI

@available(iOSApplicationExtension, unavailable)
private struct ConsentBodyViewUIViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ConsentBodyView {
        ConsentBodyView(
            bulletItems: [
                FinancialConnectionsConsent.Body.BulletItem(
                    icon: "...",
                    content: "Stripe will allow Goldilocks to access only the [data requested](https://www.stripe.com). We never share your login details with them."
                ),
                FinancialConnectionsConsent.Body.BulletItem(
                    icon: "...",
                    content: "Your data is encrypted for your protection."
                ),
                FinancialConnectionsConsent.Body.BulletItem(
                    icon: "...",
                    content: "You can [disconnect](https://www.stripe.com) your accounts at any time."
                ),
            ],
            didSelectURL: { _ in }
        )
    }
    
    func updateUIView(_ uiView: ConsentBodyView, context: Context) {}
}

@available(iOSApplicationExtension, unavailable)
struct ConsentBodyView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            ConsentBodyViewUIViewRepresentable()
                .frame(maxHeight: 200)
                .padding()
            Spacer()
        }
    }
}

#endif
