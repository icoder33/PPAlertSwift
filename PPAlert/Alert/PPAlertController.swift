//
//  PPAlertController.swift
//  PPAlert
//
//  Created by wangguangfu on 2023/2/4.
//

import Foundation
import UIKit

public struct PPAlertConfig {
    var maskColor:UIColor = UIColor(white: 0, alpha: 0.3)
    var containerColor:UIColor = UIColor.white
    var containerWidth:CGFloat = 220
    var cornerRadius:CGFloat = 4.0
    var containerBorderWidth = 0.0
    var containerBorderColor = UIColor.black.cgColor
    var shaodowOffset:CGSize = .zero
}

public enum PPAlertItemHeaderImageAnimationType {
    case none
    case rotate
    case shake
    case scale
}

public typealias PPActionHandler = ()->Void

public struct PPAlertItemHeaderImageBuilder {
    var image:UIImage?
    var imageWidth:CGFloat = 0
    var imageHeight:CGFloat = 0
    var cornerRadius:CGFloat = 0
    var animationType:PPAlertItemHeaderImageAnimationType = .none
}

public struct PPAlertItemContentBuilder {
    var title:String?
    var titleFont:UIFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    var titleColor:UIColor = UIColor.black
    var subTitle:String?
    var subTitleFont:UIFont = UIFont.systemFont(ofSize: 12.0)
    var subTitleColor:UIColor = UIColor.gray
    var topSpacing:CGFloat = 12.0
    var innerSpacing:CGFloat = 8.0
    var marginX:CGFloat = 12.0
}

public struct PPAlertItemActionBuilder {
    var actionText:String = "确定"
    var actionTextColor:UIColor = UIColor.black
    var actionFont:UIFont = UIFont.systemFont(ofSize: 14.0)
    var actionTopLineDisplay:Bool = false
    var actionTopLineColor:UIColor = UIColor.systemBackground
    var actionTopSpacing:CGFloat = 24.0
    var actionHeight:CGFloat = 40.0
    var actionHandler:PPActionHandler?
}

public struct PPAlertItemExtendBuilder {
    var extendImage:UIImage?
    var extendText:String?
    var extendSpacing:CGFloat = 4.0
    var extendFont:UIFont = UIFont.systemFont(ofSize: 14.0)
    var extendColor:UIColor = UIColor.systemBlue
    var extendWidth:CGFloat = 0.0
    var extendHeight:CGFloat = 0.0
    var extendCornerRadius = 0.0
    var extendHandler:PPActionHandler?
}

public enum PPAlertItem {
    case headerImageItem(PPAlertItemHeaderImageBuilder)
    case contentItem(PPAlertItemContentBuilder)
    case actionItem(PPAlertItemActionBuilder)
    case extendItem(PPAlertItemExtendBuilder)
}

public class PPAlertActionView: UIView {
    
    lazy var stackView:UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var actionHandler:PPActionHandler?
    
    public convenience init(_ image:UIImage?, _ innerSpacing:CGFloat?, _ title:String?, _ titleFont:UIFont?, _ titleColor:UIColor?, _ actionHandler:PPActionHandler?) {
        self.init(frame: .zero)
        self.actionHandler = actionHandler
        let innerSpacing = innerSpacing ?? 8
        stackView.spacing = innerSpacing
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        if let image {
            stackView.addArrangedSubview(imageView)
            imageView.image = image
        }
        
        let title = title ?? "按钮"
        titleLabel.font = titleFont ?? UIFont.systemFont(ofSize: 12.0)
        titleLabel.textColor = titleColor ?? UIColor.systemBlue
        titleLabel.text = title
        stackView.addArrangedSubview(titleLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func didTap() {
        guard let actionHandler else {
            return
        }
        actionHandler()
    }
}

public class PPAlertController: UIViewController {
    
    var alertConfig:PPAlertConfig = PPAlertConfig() {
        didSet(config) {
            configView(config)
        }
    }
    
    var alertItems:[PPAlertItem]?
    
    lazy var stackView:UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var containerView:UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    var containerLastView:UIView?
    var containerLastViewOffset:CGFloat = 0.0
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(alertConfig: PPAlertConfig, alertItems:[PPAlertItem]) {
        self.init(nibName: nil, bundle: nil)
        self.alertConfig = alertConfig
        self.alertItems = alertItems
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configView(alertConfig)
        setupSubView()
        updateItems(alertItems)
    }
    
    // MARK: CloseAlert
    public func closeAlert() {
        self.dismiss(animated: true)
    }
    
    // MARK: Config Views
    
    func setupSubView()  {
        // 添加StackView
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // 添加ContainerView
        stackView.addArrangedSubview(containerView)
        let HConstraint = containerView.heightAnchor.constraint(equalToConstant: 120)
        HConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: alertConfig.containerWidth),
            HConstraint
        ])
    }
    
    func configView(_ alertConfig:PPAlertConfig) {
        view.backgroundColor = alertConfig.maskColor
        containerView.backgroundColor = alertConfig.containerColor
        containerView.layer.cornerRadius = alertConfig.cornerRadius
        containerView.layer.masksToBounds = true
        containerView.layer.borderWidth = alertConfig.containerBorderWidth
        containerView.layer.borderColor = alertConfig.containerBorderColor
    }
}

extension PPAlertController {
    // MARK: Config ItemViews
    public func updateItems(_ items:[PPAlertItem]?) {
        guard let items else {
            return
        }
        // MARK: StackView清空除Container之外的view
        for (_,view) in stackView.arrangedSubviews.enumerated() {
            if view != containerView {
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
        for (_,view) in containerView.subviews.enumerated() {
            view.removeFromSuperview()
        }
        containerLastView = nil
        containerLastViewOffset = 0.0
        
        for (_,item) in items.enumerated() {
            switch item {
            case .headerImageItem(let builder):
                configHeaderImage(builder)
            case .contentItem(let builder):
                configContent(builder)
            case .actionItem(let builder):
                configAction(builder)
            case .extendItem(let builder):
                configExtend(builder)
            }
        }
        // 这里需要动态fix下高度
        fixContainerHeight()
    }
    
    // MARK: Config HeaderImageView
    func configHeaderImage(_ builder:PPAlertItemHeaderImageBuilder) {
        guard builder.image != nil, builder.imageWidth > 0, builder.imageHeight > 0 else {
            return
        }
        let headerImageView = UIImageView()
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.image = builder.image
        stackView.insertArrangedSubview(headerImageView, at: 0)
        NSLayoutConstraint.activate([
            headerImageView.widthAnchor.constraint(equalToConstant: builder.imageWidth),
            headerImageView.heightAnchor.constraint(equalToConstant: builder.imageHeight)
        ])
        stackView.setCustomSpacing(-builder.imageHeight/2, after: headerImageView)
        
        guard builder.animationType == .rotate else {
            return
        }
        // 暂时只支持一种旋转动画
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.repeatCount = MAXFLOAT
        rotationAnimation.duration = 1.5
        rotationAnimation.isRemovedOnCompletion = false
        headerImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    // MARK: Config Content
    func configContent(_ builder:PPAlertItemContentBuilder) {
        guard let title = builder.title, title.count > 0 else {
            return
        }
        let titleLabel = UILabel()
        titleLabel.font = builder.titleFont
        titleLabel.textColor = builder.titleColor
        titleLabel.text = builder.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: builder.marginX),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -builder.marginX),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: builder.topSpacing),
        ])
        containerLastView = titleLabel
        guard let subTitle = builder.subTitle, subTitle.count > 0 else {
            return
        }
        let subTitleLabel = UILabel()
        subTitleLabel.font = builder.subTitleFont
        subTitleLabel.textColor = builder.subTitleColor
        subTitleLabel.text = builder.subTitle
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.textAlignment = .center
        containerView.addSubview(subTitleLabel)
        NSLayoutConstraint.activate([
            subTitleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: builder.marginX),
            subTitleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -builder.marginX),
            subTitleLabel.topAnchor.constraint(equalTo: containerLastView!.bottomAnchor, constant: builder.innerSpacing)
        ])
        containerLastView = subTitleLabel
        containerLastViewOffset = 20.0
    }
    
    // MARK: Config Action
    func configAction(_ builder:PPAlertItemActionBuilder) {
        guard builder.actionText.count > 0 else {
            return
        }
        var topSpacing = builder.actionTopSpacing
        if builder.actionTopLineDisplay {
            let lineView = UIView()
            lineView.translatesAutoresizingMaskIntoConstraints = false
            lineView.backgroundColor = builder.actionTopLineColor
            containerView.addSubview(lineView)
            NSLayoutConstraint.activate([
                lineView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                lineView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                lineView.topAnchor.constraint(equalTo: containerLastView!.bottomAnchor, constant: topSpacing),
                lineView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
            ])
            containerLastView = lineView
            topSpacing = 0
        }
        let actionView = PPAlertActionView(nil, nil, builder.actionText, builder.actionFont, builder.actionTextColor, builder.actionHandler)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(actionView)
        NSLayoutConstraint.activate([
            actionView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            actionView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            actionView.topAnchor.constraint(equalTo: containerLastView!.bottomAnchor, constant: topSpacing),
            actionView.heightAnchor.constraint(equalToConstant: builder.actionHeight),
            actionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        containerLastView = actionView
        containerLastViewOffset = 0.0
    }
    
    // MARK: Config ExtendContent
    func configExtend(_ builder:PPAlertItemExtendBuilder) {
        guard let extendText = builder.extendText, extendText.count > 0 else {
            return
        }
        let extendView = UIView()
        extendView.backgroundColor = UIColor.white
        extendView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(extendView)
        NSLayoutConstraint.activate([
            extendView.widthAnchor.constraint(equalToConstant: builder.extendWidth),
            extendView.heightAnchor.constraint(equalToConstant: builder.extendHeight),
        ])
        
        let actionView = PPAlertActionView(builder.extendImage, builder.extendSpacing, builder.extendText, builder.extendFont, builder.extendColor, builder.extendHandler)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        extendView.addSubview(actionView)
        NSLayoutConstraint.activate([
            actionView.topAnchor.constraint(equalTo: extendView.topAnchor),
            actionView.leftAnchor.constraint(equalTo: extendView.leftAnchor),
            actionView.rightAnchor.constraint(equalTo: extendView.rightAnchor),
            actionView.bottomAnchor.constraint(equalTo: extendView.bottomAnchor),
        ])
        
        guard builder.extendCornerRadius > 0 else {
            return
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let maskLayer = CAShapeLayer()
        let maskPath = UIBezierPath(roundedRect: extendView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: builder.extendCornerRadius, height: builder.extendCornerRadius))
        maskLayer.frame = extendView.bounds
        maskLayer.path = maskPath.cgPath
        extendView.layer.mask = maskLayer
    }
    
    func fixContainerHeight() {
        guard let containerLastView else {
            return
        }
        NSLayoutConstraint.activate([
            containerLastView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -containerLastViewOffset)
        ])
    }
}
