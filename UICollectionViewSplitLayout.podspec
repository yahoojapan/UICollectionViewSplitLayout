#
# Be sure to run `pod lib lint StringStylizer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "UICollectionViewSplitLayout"
  s.version          = "1.0.0"
  s.summary          = "UICollectionViewSplitLayout makes collection view more responsive."

  s.description      = <<-DESC
UICollectionViewSplitLayout is a subclass of UICollectionViewLayout. It divides sections into one or two column.

Collection view has "Section" which organizes item collection. UICollectionViewFlowLayout layouts them from top to bottom.

On the other hands, UICollectionViewSplitLayout divides sections into two columns. You can dynamically update the width of them and which column each section is on.
                         DESC

  s.homepage         = "https://github.com/yahoojapan/UICollectionViewSplitLayout"
  s.license          = 'MIT'
  s.author           = { "Kazuhiro Hayashi" => "kahayash@yahoo-corp.jp" }
  s.source           = { :git => "https://github.com/yahoojapan/UICollectionViewSplitLayout.git", :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = "UICollectionViewSplitLayout/*.swift"
end
