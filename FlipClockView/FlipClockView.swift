//
//  FlipClockView.swift
//  FlipClock
//
//  Created by Liu Chuan on 2018/6/2.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit


class FlipClockView: UIView {
    
    //MARK: - Attribute
    
    /// 创建日历对象
    var calendar = Calendar.current
    /// 日期的组件
    var dateComponent: DateComponents!
    
    /// 时间
    var date: Date? {
        didSet {
            //默认情况下，日历未设置语言环境。
            //如果您希望收到本地化的答案，请务必首先将locale属性设置为。Locale.autoupdatingCurrent
            calendar.locale = Locale.autoupdatingCurrent
            
            // NSDateComponents默认是24小时制式
            dateComponent = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: self.date!)
            
            // 如果为十二小时制，且当前时间大于12小时，转换当前时间24小时制到12小时制
            if is12HourClock && dateComponent.hour! > 12 {
                dateComponent.hour! -= 12
            }
            
            hourItem.time = dateComponent?.hour
            minuteItem.time = dateComponent?.minute
            secondItem.time = dateComponent?.second
            
            weekdayLabel.text = getWeekdayWithNumber(dateComponent.weekday!)
            yearToDateLabel.text = "\(dateComponent.year!)年\(dateComponent.month!)月\(dateComponent.day!)日"
        }
    }
    
    ///    Whether it is a twelve-hour clock (default: 24-hour clock. FALSE,)
    var is12HourClock: Bool = false {
        didSet {
            if is12HourClock != oldValue {
                print("----- 12小时制 -------")
                let dateText = convertTimeFormat()
                timeSystemLabel.text = dateText
            }else {
                print("----- 24小时制 -----")
            }
        }
    }
    
    /// Whether working days and ordinary days are visible. (Except Sunday and Saturday) any day
    var weekdayIsVisible: Bool = false {
        didSet {
            if weekdayIsVisible != oldValue {
                weekdayLabel.isHidden = false
            }else {
                weekdayLabel.isHidden = true
            }
        }
    }
    
    ///    Is visible in seconds
    var secondIsVisible: Bool = false {
        didSet {
            if secondIsVisible != oldValue {
                secondItem.isHidden = false
            }else {
                secondItem.isHidden = true
            }
        }
    }
    
    ///    Is the year, month and day visible
    var yearMonthDayIsVisible: Bool = false {
        didSet {
            if yearMonthDayIsVisible != oldValue {
                yearToDateLabel.isHidden = false
            }else {
                yearToDateLabel.isHidden = true
            }
        }
    }
    
    /// Font
    var font: UIFont? {
        didSet {
            hourItem.font = font
            minuteItem.font = font
            secondItem.font = font
        }
    }
    
    ///    Text color
    var textColor: UIColor? {
        didSet {
            hourItem.textColor = textColor
            minuteItem.textColor = textColor
            secondItem.textColor = textColor
        }
    }
    
    //MARK: - Lazy loading
    
    /// hour
    private lazy var hourItem: FlipClockItem = {
        let hour = FlipClockItem()
        hour.type = .FlipClockItemTypeHour
        return hour
    }()
    
    /// minute
    private lazy var minuteItem: FlipClockItem = {
        let minute = FlipClockItem()
        minute.type = .FlipClockItemTypeMinute
        return minute
    }()
    
    /// second
    private lazy var secondItem: FlipClockItem = {
        let second = FlipClockItem()
        second.type = .FlipClockItemTypeSecond
        return second
    }()
    
    /// Time system label
    private lazy var timeSystemLabel: UILabel = {
        let timeSystemLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 215, height: 30))
        timeSystemLabel.textColor = .lightText
        timeSystemLabel.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 20)
        timeSystemLabel.backgroundColor = .clear
        return timeSystemLabel
    }()
    
    ///    Working day label
    private lazy var weekdayLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: 215, height: 30))
        label.textColor = .lightText
        label.isHidden = true   //        The default is: hidden
        label.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 20)
        label.backgroundColor = .clear
        return label
    }()
    
    /// year month day label
    private lazy var yearToDateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: 215, height: 30))
        label.textColor = .lightText
        label.isHidden = true   // 默认为：隐藏
        label.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 20)
        label.backgroundColor = .clear
        return label
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
extension FlipClockView {
    
    /** 布局尺寸必须在 layoutSubViews 中, 否则获取的 size 不正确 **/
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /// 间距
        let margin: CGFloat = 0.07 * bounds.size.width
        /// 每个item的宽度
        let itemW: CGFloat = (bounds.size.width - 4 * margin) / 3
        /// 每个item的Y值
        let itemY: CGFloat = (bounds.size.height - itemW) / 2
        
        hourItem.frame = CGRect(x: margin, y: itemY, width: itemW, height: itemW)
        minuteItem.frame = CGRect(x: hourItem.frame.maxX + margin, y: itemY, width: itemW, height: itemW)
        secondItem.frame = CGRect(x: minuteItem.frame.maxX + margin, y: itemY, width: itemW, height: itemW)
    }
}

// MARK: - Configuration
extension FlipClockView {
    
    private func configUI() {
        addSubview(hourItem)
        addSubview(minuteItem)
        addSubview(secondItem)
        hourItem.addSubview(timeSystemLabel)
        minuteItem.addSubview(weekdayLabel)
        secondItem.addSubview(yearToDateLabel)
    }
}

//MARK: - Convert Time Format
extension FlipClockView {
    
    ///    Conversion time format (24 -> 12 hour format)
    ///
    /// - Returns: String
    func convertTimeFormat() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en-US")
        // Set the time format
        // "a" is the ICU symbol for AM/PM indicator. It can never be "A" because ICU uses "A" to mean something completely different (the number of milliseconds in a day).
        df.dateFormat = "a"
        df.amSymbol = "AM"
        df.pmSymbol = "PM"
        df.timeZone = TimeZone(identifier: "America/Los_Angeles")
        print("Current timezone-\(TimeZone.current)----\(NSTimeZone.system)")
        
        // 调用string方法进行转换
        let dateString = df.string(from: Date())
        print(dateString)   // "PM"
        return dateString
    }
    
    /// 根据数字获取工作日
    /// - Parameter number: 数字
    func getWeekdayWithNumber(_ number: Int) -> String? {
        switch number {
        case 1:
            return "Воскресенье"
        case 2:
            return "Понедельник"
        case 3:
            return "Вторник"
        case 4:
            return "Среда"
        case 5:
            return "Четверг"
        case 6:
            return "Пятница"
        case 7:
            return "Суббота"
        default:
            return ""
        }
    }
}
