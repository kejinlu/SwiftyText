<img src="/Assets/swifty-text-logo.png" height="80"/>  

----

[![Build Status](https://travis-ci.org/kejinlu/SwiftyText.svg?branch=master)](https://travis-ci.org/kejinlu/SwiftyText)
 
[English](Docs/README-en.md)

### 目标及特性
- **链接属性(Link Attribute)**  设置后，对应区域的文本便支持点击效果，单击以及长按都有对应的delegate方法
- **手势自定义**  Link的手势支持点击(Tap)以及长按(LongPress)， 手势的触发事件都可以通过delegate方法进行处理
- **增强的Attachment**  支持基于View的附件，支持和文本垂直方向的各种对其方式：靠底对齐，居中对齐，靠顶对齐，根据文本高度进行缩放
- **Text Parser**  设置后完成文本模式的识别和文本属性的自动设置，支持自动将识别结果加上link属性，比如识别文本中的所有URL链接，变成可以点击的
- **文本异步渲染**，提升用户体验
- **Accessibility**，支持Voice Over便于盲人使用

### 知识点
如果你想通过阅读源码来学习iOS相关的编程知识，那么通过本项目你可以学到如下一些知识点：

- 如何直接通过TextKit来渲染界面 
- 通过CAShapeLayer来实现一些特殊形状的layer
- 如何实现自定义的手势识别器(Gesture Recognizer)，以及多个手势识别器之间如何协同
- 如果通过继承NSTextAttachment并覆盖attachmentBoundsForTextContainer方法来实现attachment的自定义的垂直对齐方式
- 自定义界面控件如何实现Voice Over特性

### 要求
- iOS 8.0+
- XCode 7.1+

### 集成

你可以使用 [Carthage](https://github.com/Carthage/Carthage) 来集成 SwiftyText， 将以下依赖添加到你的Cartfile中:

```
github "kejinlu/SwiftyText"
```

### 使用

#### 基本设置
- text 设置此属性 会替换掉原先设置的attributedText的文本,新文本使用textColor,font,textAlignment,lineSpacing这些属性进行样式的设置
- attributedText 设置此属性会替换原先的text文本以及所有的相关样式，但是之后重新设置textColor,font,textAlignment,lineSpacing,paragraphSpacing,firstLineHeadIndent这些属性的时候，会将样式重新设置到整个attributedText
- numberOfLines将设置文本控件的最大行数，lineBreakMode设置文本的断行模式（目前发现一个Text Kit的bug，当lineBreakMode设置为NSLineBreakByCharWrapping的时候numberOfLines起不了约束的作用）


SwiftyText 提供了一些NSAttributedString以及NSMutableAttributedString的扩展方法，方便使用者快捷设置自己的Attributed String

```
extension NSAttributedString {
    public func isValidRange(range: NSRange) -> Bool
    public func entireRange() -> NSRange
    public func proposedSizeWithConstrainedSize(constrainedSize: CGSize, exclusionPaths: [UIBezierPath]?, lineBreakMode: NSLineBreakMode?, maximumNumberOfLines: Int?) -> CGSize //计算最佳Size
    public func neighbourFontDescenderWithRange(range: NSRange) -> CGFloat
}

extension NSMutableAttributedString {
    public var font: UIFont?
    public var foregroundColor: UIColor?
    public func setFont(font: UIFont?, range: NSRange)
    public func setForegroundColor(foregroundColor: UIColor?, range: NSRange)
    public func setLink(link: SwiftyText.SwiftyTextLink?, range: NSRange)
    public func insertAttachment(attachment: SwiftyText.SwiftyTextAttachment, atIndex loc: Int)
}
```

这里创建一个SwiftyLabel, 代码如下：


```objc
let label = SwiftyLabel(frame: CGRectMake(0, 0, 300, 400))
label.center = self.view.center
label.delegate = self
label.backgroundColor = UIColor(red: 243/255.0, green: 1, blue: 236/255.0, alpha: 1)
label.text = "Swift is a powerful and intuitive programming language for iOS, OS X, tvOS, and watchOS.  https://developer.apple.com/swift/resources/ . Writing Swift code is interactive and fun, the syntax is concise yet expressive, and apps run lightning-fast. Swift is ready for your next project — or addition into your current app — because Swift code works side-by-side with Objective-C.  "
label.textContainerInset = UIEdgeInsetsMake(6, 6, 6, 6)
label.font = UIFont.systemFontOfSize(14)
label.textColor = UIColor.blackColor()
label.firstLineHeadIndent = 24
label.drawsTextAsynchronously = true
```

#### Link
这里的链接指的是文本中可以点击的内容。
链接属性在SwiftyText中使用 SwiftyTextLink来表示,SwiftyTextLink中包含如下的一些属性:
- attributes 设置链接属性对应的文本的式样，使用标准的NSAttributedString的attributes
- highlightedAttributes 点击高亮时 对应文本的样式属性，非高亮的时候会恢复到高亮之前的样式
- highlightedMaskRadius，highlightedMaskColor 分别设置点击时 文本上的蒙层边角半径以及颜色
- URL,date,timeZone,phoneNumber,addressComponents 这些是可能出现的常见的链接类型的相关值，如果不是这些特定链接，可以使用userInfo自己进行设置

代码示例：

```objc
let link = SwiftyTextLink()
link.URL = NSURL(string: "https://developer.apple.com/swift/")
link.attributes = [NSForegroundColorAttributeName:UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue]
label.setLink(link, range: NSMakeRange(0, 5))
```


#### TextParser
有很多时候我们需要对特定的模式的文本做特殊处理，诸如文本替换，或者特定的文本设置特定的属性，诸如颜色，字体等，这个时候我们便可以通过实现SwiftyTextParser protocol来实现自己的Text Parser，设置到SwiftyLabel中。Text Parser存在的好处在于处理逻辑的复用。
在SwiftyText中定义了一种叫做Detector的特殊Text Parser，可以通过设置正则以及对应的属性的方式来创建一个Parser。
还有一个特殊的Text Parser叫做 SwiftyTextSuperParser，它其实就是一个parser container， 是一个Text Parser的容器，这样就可以将多个 Text Parser合并成一个。

下面主要讲解下Detector
- name detector的名字
- linkable 是否是链接，如果是链接的话会对匹配的文本设置上Link属性，支持点击, 你还可以通过linkGestures来设置链接支持的手势
- regularExpression 匹配的模式，类型为NSRegularExpression的实例或者其子类的对象
- attributes 匹配的文本需要设置的属性，比如特定颜色，字体，下划线等
- highlightedAttributes 当linkable为YES时，此属性用来决定匹配的文本的点击时的高亮属性
- replacementBlock 当匹配的文本的属性的设置比较复杂的时候，没法通过简单的attributes来实现的时候，可以通过此block返回替换的attributedText

```objc
let detector = SwiftyTextDetector.detectorWithType([.URL,.Address])
if detector != nil {
    label.parser = detector
}
```

#### Attachment
SwiftyTextAttachment在NSTextAttachment上做了增强，同时支持基于图片以及基于UIView的Attachment。
图片，UIView类型的附件都支持和文本在纵向上的各种对齐方式:靠顶对齐，居中，靠底对齐，缩放以适配文本高度，都支持通过设置padding来控制前后的padding。
图片Attachment还支持通过设置imageSize来控制图片的大小（当垂直对齐为 靠顶对齐，居中，靠底对齐时起作用）


```objc
 let imageAttachment = SwiftyTextAttachment()
 imageAttachment.image = UIImage(named: "logo")
 imageAttachment.attachmentTextVerticalAlignment = .Top
 label.insertAttachment(imageAttachment, atIndex: label.textStorage.length)
 
 let sliderAttachment = SwiftyTextAttachment()
 let slider = UISlider()
 sliderAttachment.contentView = slider;
 sliderAttachment.padding = 3.0
 sliderAttachment.attachmentTextVerticalAlignment = .Center
 label.insertAttachment(sliderAttachment, atIndex: 8)
```

下图为demo的效果截图：

<img src="/Assets/demo.png" height="480"/>

#### 其余Text Kit的特性
其余的Text Kit的特性比如exclusionPaths，可以通过SwiftyLabel的exclusionPaths的属性进行设置。

### 许可证
SwiftyText 基于 MIT license进行开源。 具体详情请查看根目录下的LICENSE文件。
