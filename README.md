<img src="/Assets/swifty-text-logo.png" height="80"/>  <a href="Docs/README-en.md">English</a>

----

[![Build Status](https://travis-ci.org/kejinlu/SwiftyText.svg?branch=master)](https://travis-ci.org/kejinlu/SwiftyText)
 
### 目标及特性
- 链接属性(Link Attribute)，设置后，对应区域的文本便支持点击效果，单击以及长按都有对应的delegate方法
- 增强的Attachment，支持基于的附件，支持和文本垂直方向的各种对其方式：靠底对齐，居中对齐，靠顶对齐，根据文本高度进行缩放
- Text Detectors，设置后完成文本模式的识别和文本属性的自动设置，支持自动将识别结果加上link属性，比如识别文本中的所有URL链接，变成可以点击的
- 文本支持异步渲染，提升用户体验
- Accessibility，支持Voice Over便于盲人使用

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
label.textStorage.setLink(link, range: NSMakeRange(0, 5))
```


#### TextDetector
TBTextDetector是用来描述text storage特定文本识别的模式，以及对应式样的描述, 具体的包括下面一些属性

- name detector的名字
- linkable 是否是链接，如果是链接的话会对匹配的文本设置上Link属性，支持点击
- regularExpression 匹配的模式，类型为NSRegularExpression的实例或者其子类的对象
- attributes 匹配的文本需要设置的属性，比如特定颜色，字体，下划线等
- highlightedAttributes 当linkable为YES时，此属性用来决定匹配的文本的点击时的高亮属性
- replacementBlock 当匹配的文本的属性的设置比较复杂的时候，没法通过简单的attributes来实现的时候，可以通过此block返回替换的attributedText

```objc
let detector = SwiftyTextDetector.detectorWithType([.URL,.Address])
if detector != nil {
    label.addTextDetector(detector!)
}
```

#### Attachment
SwiftyTextAttachment在NSTextAttachment上做了增强，同时支持基于图片以及基于UIView的Attachment。图片，UIView类型的附件都支持和文本在纵向上的各种对齐方式:靠顶对齐，居中，靠底对齐，缩放以适配文本高度。其中基于UIView的Attachment还可以通过设置contentViewPadding来设置左右的padding。

```objc
 let imageAttachment = SwiftyTextAttachment()
 imageAttachment.image = UIImage(named: "logo")
 imageAttachment.attachmentTextVerticalAlignment = .Top
 label.textStorage.insertAttachment(imageAttachment, atIndex: label.textStorage.length)
 
 let sliderAttachment = SwiftyTextAttachment()
 let slider = UISlider()
 sliderAttachment.contentView = slider;
 sliderAttachment.contentViewPadding = 3.0
 sliderAttachment.attachmentTextVerticalAlignment = .Center
 label.textStorage.insertAttachment(sliderAttachment, atIndex: 8)
```

下图为demo的效果截图：

<img src="/Assets/demo.png" height="480"/>

#### 其余Text Kit的特性
其余的Text Kit的特性可以通过 NSTextStorage， NSLayoutManager，以及NSTextContainer来实现。 比如要实现exclusionPaths

### 许可证
SwiftyText 基于 MIT license进行开源。 具体详情请查看根目录下的LICENSE文件。
