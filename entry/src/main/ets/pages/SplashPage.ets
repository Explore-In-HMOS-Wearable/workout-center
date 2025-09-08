import router from '@ohos.router';
import LottieAnimation from '../animation/LottieAnimation'
import { ConstantUI } from '../util/ConstantUI';

@Entry
@Component
export struct SplashPage {
  aboutToAppear() {
    setTimeout(() => {
      router.replaceUrl({ url: 'pages/Index' })
    }, 5000)
  }

  build() {
    Column() {
      LottieAnimation({ politeChickyPath: 'resources/rawfile/splash.json' })
        .width(ConstantUI.FULL_WIDTH)
        .height(ConstantUI.FULL_HEIGHT)
    }
    .width(ConstantUI.FULL_WIDTH)
    .height(ConstantUI.FULL_HEIGHT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
