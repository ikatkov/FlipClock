//
//  FlipClockLabel.swift
//  FlipClock
//
//  Created by Liu Chuan on 2018/6/3.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit


///Start value of next label
private let NextLabelStartValue: CGFloat = 0.01


class FlipClockLabel: UIView {

    //MARK: Attribute
    
    ///    Animation execution progress
    var animateValue: CGFloat = 0.0
    
    /// Font
    var font: UIFont? {
        didSet {
            timeLabel.font = font
            foldLabel.font = font
            nextLabel.font = font
        }
    }
    
    ///    Text color
    var textColor: UIColor? {
        didSet {
            timeLabel.textColor = textColor
            foldLabel.textColor = textColor
            nextLabel.textColor = textColor
        }
    }
    
    ///    Text alignment (default, left aligned)
    var textAlignment: NSTextAlignment = .left {
        didSet {
            timeLabel.textAlignment = textAlignment
            foldLabel.textAlignment = textAlignment
            nextLabel.textAlignment = textAlignment
        }
    }
    
    //MARK: Lazy loading
    
    ///    Current time label
    private lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        configLabel(timeLabel)
        return timeLabel
    }()
    
    ///    Flip animation label
    private lazy var foldLabel: UILabel = {
        let foldLabel = UILabel()
        configLabel(foldLabel)
        return foldLabel
    }()
    
    ///    Next time label
    private lazy var nextLabel: UILabel = {
        let nextLabel = UILabel()
        configLabel(nextLabel)
        return nextLabel
    }()
    
    ///    The container where the label is placed
    private lazy var labelContainer: UIView = {
        let labelContainer = UIView()
        labelContainer.backgroundColor = UIColor(red: 46 / 255.0, green: 43 / 255.0, blue: 46 / 255.0, alpha: 1)
        return labelContainer
    }()
    
    ///Refresh UI tools
    private lazy var link: CADisplayLink = {
        let link = CADisplayLink(target: self, selector: #selector(updateAnimateLabel))
        return link
        
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension FlipClockLabel {
    
    /** 布局尺寸必须在 layoutSubViews 中, 否则获取的 size 不正确 **/
    override func layoutSubviews() {
        super.layoutSubviews()
        labelContainer.frame = self.bounds
        timeLabel.frame = labelContainer.bounds
        nextLabel.frame = labelContainer.bounds
        foldLabel.frame = labelContainer.bounds
    }
}

// MARK: - Configuration
extension FlipClockLabel {
    
    ///Configure UI
    private func configUI() {
        addSubview(labelContainer)
        labelContainer.addSubview(timeLabel)
        labelContainer.addSubview(nextLabel)
        labelContainer.addSubview(foldLabel)
    }
    
    ///    Configure UILabel
    ///
    /// - Parameter label: UILabel
    private func configLabel(_ label: UILabel) {
        //label.textAlignment = .center
        label.textColor = UIColor.lightText
        label.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 200)
        label.layer.masksToBounds = true
        label.backgroundColor = #colorLiteral(red: 0.06778538942, green: 0.06845653189, blue: 0.06845653189, alpha: 1)
    }

    /// 更新时间
    ///
    /// - Parameters:
    ///   - time: 时间
    ///   - nextTime: 下一个时间
    public func updateTime(_ time: Int, nextTime: Int) {
        timeLabel.text = "\(time)"
        foldLabel.text = "\(time)"
        nextLabel.text = "\(nextTime)"
        nextLabel.layer.transform = nextLabelStartTransform()
        nextLabel.isHidden = true
        animateValue = 0.0
        start()
    }
}

//MARK: - Animations
extension FlipClockLabel {
    
    /// 下一个label开始动画 默认label起始角度
    ///
    /// - Returns: CATransform3D
    private func nextLabelStartTransform() -> CATransform3D {
        var t: CATransform3D = CATransform3DIdentity
        t.m34 = CGFloat.leastNormalMagnitude
        t = CATransform3DRotate(t, CGFloat(.pi * Double(NextLabelStartValue)), -1, 0, 0)
        return t
    }
    
    /// 更新动画label
    @objc private func updateAnimateLabel() {
        animateValue += 2 / 60.0
        if animateValue >= 1 {
            stop()
            return
        }
        var t: CATransform3D = CATransform3DIdentity
        t.m34 = CGFloat.leastNormalMagnitude
        
        // 绕x轴进行翻转
        t = CATransform3DRotate(t, .pi * animateValue, -1, 0, 0)
        if animateValue >= 0.5 {
            // 当翻转到和屏幕垂直时，翻转y和z轴
            t = CATransform3DRotate(t, .pi, 0, 0, 1)
            t = CATransform3DRotate(t, .pi, 0, 1, 0)
        }
        foldLabel.layer.transform = t
        
        // 当翻转到和屏幕垂直时，切换动画label的字
        foldLabel.text = animateValue >= 0.5 ? nextLabel.text : timeLabel.text
        
        // 当翻转到指定角度时，显示下一秒的时间
        nextLabel.isHidden = animateValue <= NextLabelStartValue
    }
    
    /// 开始动画
    private func start() {
        link.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    /// 停止动画
    private func stop() {
        link.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
}
