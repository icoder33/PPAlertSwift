//
//  ViewController.swift
//  PPAlert
//
//  Created by wangguangfu on 2023/2/4.
//

import UIKit

class ViewController: UIViewController {
    
    enum ViewStatus {
        case none
        case show
        case process
        case done
    }
    
    var currentStatus:ViewStatus = .none {
        didSet {
            updateViewStatus(currentStatus)
        }
    }
    
    var alert:PPAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let testButton = UIButton(type: .custom)
        testButton.frame.size = CGSize(width: 80, height: 80)
        testButton.center = view.center
        testButton.setTitle("弹出Alert", for: .normal)
        testButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        testButton.setTitleColor(UIColor.systemBlue, for: .normal)
        testButton.layer.cornerRadius = 40
        testButton.layer.masksToBounds = true
        testButton.layer.borderColor = UIColor.systemBlue.cgColor
        testButton.layer.borderWidth = 1
        testButton.addTarget(self, action: #selector(testForAlert), for: .touchUpInside)
        view.addSubview(testButton)
    }


    @objc
    func testForAlert() {
        currentStatus = .show
    }
    
    func updateViewStatus(_ status:ViewStatus) {
        switch status {
        case.none:
            if let alert {
                alert.closeAlert()
            }
        case.show:
            var alertConig = PPAlertConfig()
            alertConig.containerBorderWidth = 1.0 / UIScreen.main.scale
            let headerImageBuilder = PPAlertItemHeaderImageBuilder(
                image: UIImage(named: "start"),
                imageWidth: 64,
                imageHeight: 64,
                animationType: .none)
            let contentBuilder = PPAlertItemContentBuilder(
                title: "请选择是否处理事务",
                titleFont: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                titleColor: UIColor.black,
                topSpacing: 40
            )
            let actionBuilder = PPAlertItemActionBuilder(
                actionText:"知道了",
                actionTopLineDisplay: true,
                actionTopLineColor: UIColor.gray,
                actionHandler: { [unowned self] in
                    print("changeToClose")
                    self.currentStatus = .none
                }
            )
            let extendBuilder = PPAlertItemExtendBuilder(
                extendImage: UIImage(named: "extend"),
                extendText: "处理事务",
                extendWidth: 120.0,
                extendHeight: 44.0,
                extendCornerRadius: 4.0,
                extendHandler: { [unowned self] in
                    print("changeToProcess")
                    self.currentStatus = .process
                    // 处理3s的任务
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.currentStatus = .done
                    }
                }
            )
            let alertItems = [
                PPAlertItem.headerImageItem(headerImageBuilder),
                PPAlertItem.contentItem(contentBuilder),
                PPAlertItem.actionItem(actionBuilder),
                PPAlertItem.extendItem(extendBuilder)
            ]
            alert = PPAlertController(alertConfig: alertConig, alertItems: alertItems)
            if alert != nil {
                self.present(alert!, animated: true)
            }
        case.process:
            let headerImageBuilder = PPAlertItemHeaderImageBuilder(
                image: UIImage(named: "process"),
                imageWidth: 64,
                imageHeight: 64,
                animationType: .rotate)
            let contentBuilder = PPAlertItemContentBuilder(
                title: "正在加急处理任务中",
                titleFont: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                titleColor: UIColor.black,
                subTitle: "请稍等片刻",
                subTitleFont: UIFont.systemFont(ofSize: 12.0),
                subTitleColor:UIColor.gray,
                topSpacing: 40,
                innerSpacing: 6
            )
            let alertItems = [
                PPAlertItem.headerImageItem(headerImageBuilder),
                PPAlertItem.contentItem(contentBuilder)
            ]
            alert?.updateItems(alertItems)
        case.done:
            let headerImageBuilder = PPAlertItemHeaderImageBuilder(
                image: UIImage(named: "done"),
                imageWidth: 64,
                imageHeight: 64,
                animationType: .none)
            let contentBuilder = PPAlertItemContentBuilder(
                title: "已处理完成～",
                titleFont: UIFont.systemFont(ofSize: 14.0, weight: .medium),
                titleColor: UIColor.black,
                topSpacing: 40
            )
            let actionBuilder = PPAlertItemActionBuilder(
                actionText:"知道了",
                actionTopLineDisplay: true,
                actionTopLineColor: UIColor.gray,
                actionHandler: { [unowned self] in
                    print("changeToClose")
                    self.currentStatus = .none
                }
            )
            let alertItems = [
                PPAlertItem.headerImageItem(headerImageBuilder),
                PPAlertItem.contentItem(contentBuilder),
                PPAlertItem.actionItem(actionBuilder)
            ]
            alert?.updateItems(alertItems)
        }
    }
}

