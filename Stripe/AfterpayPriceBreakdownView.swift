//
//  AfterpayPriceBreakdownView.swift
//  StripeiOS
//
//  Created by Jaime Park on 6/9/21.
//  Copyright © 2021 Stripe, Inc. All rights reserved.
//
import Foundation
import UIKit
import SafariServices
@_spi(STP) import StripeUICore

/// For internal SDK use only
@objc(STP_Internal_AfterpayPriceBreakdownView)
class AfterpayPriceBreakdownView: UIView {
    private let afterPayClearPayLabel = UILabel()
    
    private lazy var afterpayMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = STPImageLibrary.afterpayLogo(locale: locale)
        imageView.tintColor = ElementsUITheme.current.colors.parentBackground.contrastingColor

        return imageView
    }()
    private lazy var afterpayMarkImage: UIImage = {
        return STPImageLibrary.afterpayLogo(locale: locale)
    }()
    private lazy var infoImage: UIImage = {
        return STPImageLibrary.safeImageNamed("afterpay_icon_info@3x")
    }()

    private lazy var infoURL: URL? = {
        let regionCode = Locale.current.regionCode ?? "us"
        return URL(string: "https://static-us.afterpay.com/javascript/modal/\(regionCode.lowercased())_rebrand_modal.html")
    }()

    static func numberOfInstallments(currency: String) -> Int {
        return currency.uppercased() == "EUR" ? 3 : 4
    }

    let locale: Locale
    
    init(amount: Int, currency: String, locale: Locale = Locale.autoupdatingCurrent) {
        self.locale = locale
        super.init(frame: .zero)
        let numInstallments = Self.numberOfInstallments(currency: currency)
        let installmentAmount = amount / numInstallments
        let installmentAmountDisplayString = String.localizedAmountDisplayString(for: installmentAmount, currency: currency)
        
        afterPayClearPayLabel.attributedText = generateAfterPayClearPayString(numInstallments: numInstallments,
                                                                              installmentAmountString: installmentAmountDisplayString)
        afterPayClearPayLabel.numberOfLines = 0
        afterPayClearPayLabel.translatesAutoresizingMaskIntoConstraints = false
        afterPayClearPayLabel.isUserInteractionEnabled = true
        addSubview(afterPayClearPayLabel)

        NSLayoutConstraint.activate([
            afterPayClearPayLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor),
            afterPayClearPayLabel.topAnchor.constraint(
                equalTo: topAnchor),
            afterPayClearPayLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            afterPayClearPayLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        afterPayClearPayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapInfoButton)))
    }
    
    override init(frame: CGRect) {
        self.locale = Locale.autoupdatingCurrent
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func generateAfterPayClearPayString(numInstallments: Int, installmentAmountString: String) -> NSMutableAttributedString {
        let amountStringAttributes = [
            NSAttributedString.Key.font: ElementsUITheme.current.fonts.subheadlineBold,
            .foregroundColor: ElementsUITheme.current.colors.bodyText
        ]
        let stringAttributes = [
            NSAttributedString.Key.font: ElementsUITheme.current.fonts.subheadline,
            .foregroundColor: ElementsUITheme.current.colors.bodyText
        ]
        let template = STPLocalizedString("Pay in <num_installments/> interest-free payments of <installment_price/> with <img/>",
                                          "Pay in templated string for afterpay/clearpay")

        let resultingString = NSMutableAttributedString()
        resultingString.append(NSAttributedString(string: ""))
        guard let numInstallmentsRange = template.range(of: "<num_installments/>"),
              let installmentPrice = template.range(of: "<installment_price/>"),
              let img = template.range(of: "<img/>") else {
            return resultingString
        }

        var numInstallmentsAppended = false
        var installmentPriceAppended = false
        var imgAppended = false

        for (indexOffset, currCharacter) in template.enumerated() {
            let currIndex = template.index(template.startIndex, offsetBy: indexOffset)
            if numInstallmentsRange.contains(currIndex) {
                if numInstallmentsAppended {
                    continue
                }
                numInstallmentsAppended = true
                resultingString.append(NSAttributedString(string: "\(numInstallments)",
                                                          attributes: stringAttributes))
            } else if installmentPrice.contains(currIndex) {
                if installmentPriceAppended {
                    continue
                }
                installmentPriceAppended = true
                resultingString.append(NSAttributedString(string: installmentAmountString,
                                                          attributes: amountStringAttributes))
            } else if img.contains(currIndex) {
                if imgAppended {
                    continue
                }
                imgAppended = true
                let titleFont = stringAttributes[NSAttributedString.Key.font] as! UIFont
                let clearPay = attributedStringOfImageWithoutLink(uiImage: afterpayMarkImage, font: titleFont)
                let infoButton = attributedStringOfImageWithoutLink(uiImage: infoImage, font: titleFont)
                resultingString.append(clearPay)
                resultingString.append(NSAttributedString(string: "\u{00A0}\u{00A0}", attributes: stringAttributes))
                resultingString.append(infoButton)
            } else {
                resultingString.append(NSAttributedString(string: String(currCharacter),
                                                          attributes: stringAttributes))
            }
        }
        return resultingString
    }

    private func attributedStringOfImageWithoutLink(uiImage: UIImage, font: UIFont) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = boundsOfImage(font: font, uiImage: uiImage)
        imageAttachment.image = uiImage
        return NSAttributedString(attachment: imageAttachment)
    }

    // https://stackoverflow.com/questions/26105803/center-nstextattachment-image-next-to-single-line-uilabel
    private func boundsOfImage(font: UIFont, uiImage: UIImage) -> CGRect {
        return CGRect(x: 0,
                      y: (font.capHeight - uiImage.size.height).rounded() / 2,
                      width: uiImage.size.width,
                      height: uiImage.size.height)
    }

    @objc
    private func didTapInfoButton() {
        if let url = infoURL {
            let safariController = SFSafariViewController(url: url)
            safariController.modalPresentationStyle = .overCurrentContext
            parentViewController?.present(safariController, animated: true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        afterpayMarkImageView.tintColor = ElementsUITheme.current.colors.parentBackground.contrastingColor
    }
}

private extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
