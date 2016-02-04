<img src="../Assets/swifty-text-logo.png" height="80"/>

----

[![Build Status](https://travis-ci.org/kejinlu/SwiftyText.svg?branch=master)](https://travis-ci.org/kejinlu/SwiftyText)
 
### Goals & Features
- **Link Attribute** Gestures support, delegate methods
- **Attachment Enhancements** Vertical alignment, view based attachment
- **Text Parser** 
- **Asynchronous Text Rendering** Render text in background thread
- **Accessibility**  Voiceover supported for links

### Requirements
- iOS 8.0+
- XCode 7.1+

### Integration

You can use [Carthage](https://github.com/Carthage/Carthage) to install SwiftyText by adding it to your Cartfile:

```
github "kejinlu/SwiftyText"
```

Of course, you can use [Cocoapods](https://github.com/CocoaPods/CocoaPods).

```
platform :ios, '8.0'
use_frameworks!
pod 'SwiftyText'
```

### Usage

#### Basic properties
- **text** Assigning a new value to this property also replaces the value of the attributedText property with the same text, albeit without any inherent style attributes. Instead the label styles the new string using the font, textColor, and other style-related properties of the class.
- **attributedText** Assigning a new value to this property also replaces the value of the text property with the same string data, albeit without any formatting information. In addition, assigning a new a value updates the values in the font, textColor, and other style-related properties so that they reflect the style information starting at location 0 in the attributed string.
- **numberOfLines** This property controls the maximum number of lines to use in order to fit the label’s text into its bounding rectangle. The default value for this property is 0 which means using as many lines as needed（By now found a bug with Text Kit，numberOfLines will not work when lineBreakMode set to NSLineBreakByCharWrapping)



Here gives an example of creating a SwiftyLabel：


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
The **Link** Attribute convert a range of text to clickable item.
The **SwiftyTextLink** class is a model class designed to describe the link style and infomation.
- **attributes**: Link attributes for the target text
- **highlightedAttributes**: When highlighted, set the highlightedAttributes to the target text
- **highlightedMaskRadius**, **highlightedMaskColor**: Stylish for mask when highlighted
- **URL** ,**date**,**timeZone**,**phoneNumber**,**addressComponents**: These properties used for specialized link such as URL links, phoneNumber links

Example：

```objc
let link = SwiftyTextLink()
link.URL = NSURL(string: "https://developer.apple.com/swift/")
link.attributes = [NSForegroundColorAttributeName:UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue]
label.textStorage.setLink(link, range: NSMakeRange(0, 5))
```


#### TextDetector

The properties of  **TBTextDetector** class:

- **name**: The name of the detector
- **linkable**: Should make the matched text to be clickable 
- **regularExpression**: The instance of  NSRegularExpression class or subclass
- **attributes**: Text attributes for matched text
- **highlightedAttributes**: for the link attribute when linable is YES
- **replacementBlock**: When **attributes** is not statisfy the requirements use this block to return the attributed text for replacement

Example:

```objc
let detector = SwiftyTextDetector.detectorWithType([.URL,.Address])
if detector != nil {
    label.addTextDetector(detector!)
}
```

#### Attachment
SwiftyTextAttachment makes some enhancements to vertical alignment and attachment type. With SwiftyTextAttachment you can treat a view as attachement.

Example:

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

The screenshot of the demo:

<img src="/Assets/demo.png" height="480"/>

#### Other Text Kit Features
Other features of Text Kit can be achieved by NSTextStorage，NSLayoutManager，and NSTextContainer through properties of SwiftyLabel.

### Licenese
SwiftyText is released under the MIT license. See LICENSE for details.