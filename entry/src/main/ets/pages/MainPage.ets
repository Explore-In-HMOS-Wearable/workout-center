import sensor from '@system.sensor'
import { TimerService, TimerStatus } from '../core/services/TimerService'
import { ConstantUI } from '../util/ConstantUI'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct MainPage {
  @State status: TimerStatus = TimerStatus.STOPPED
  private timerService = TimerService.getInstance()
  private isDown: boolean = false
  private lastZ: number = 0
  private lastTimestamp: number = Date.now()

  aboutToDisappear() {
    this.stopSensor()
  }

  build() {
    Gauge({
      value: this.timerService.remainingSeconds,
      min: 0,
      max: this.timerService.totalSeconds
    }) {
      Column({ space: ConstantUI.SIZE_10 }) {
        Row() {
          Text(this.formatTime(this.timerService.remainingSeconds))
            .fontSize($r('app.float.timer_font_size'))
            .fontWeight(FontWeight.Bold)
        }
        .justifyContent(FlexAlign.Center)

        Text(`Reps: ${this.timerService.repCount} / ${this.timerService.targetRepCount}`)
          .fontSize(ConstantUI.SIZE_22)
          .fontWeight(FontWeight.Bold)
          .margin({ top: ConstantUI.SIZE_10 })

        Row({ space: ConstantUI.SIZE_10 }) {
          Button(this.status === TimerStatus.RUNNING ? $r('app.string.main_pause') : $r('app.string.main_start'))
            .fontSize($r('app.float.button_font_size'))
            .width(ConstantUI.BUTTON_WIDTH_HALF)
            .onClick(() => {
              if (this.status === TimerStatus.RUNNING) {
                this.timerService.pause()
                this.status = TimerStatus.PAUSED
                this.stopSensor()
              } else {
                this.timerService.setOnTimerFinish(() => {
                  this.status = TimerStatus.STOPPED
                  router.pushUrl({
                    url: 'pages/DetailPage',
                    params: {
                      reason: 'time',
                      reps: this.timerService.repCount,
                      duration: this.timerService.totalSeconds
                    }
                  })
                  this.stopSensor()

                })

                this.timerService.setOnRepsComplete(() => {
                  this.status = TimerStatus.STOPPED
                  this.stopSensor()
                  router.pushUrl({
                    url: 'pages/DetailPage',
                    params: {
                      reason: 'reps',
                      reps: this.timerService.repCount,
                      duration: this.timerService.totalSeconds
                    }
                  })
                })

                this.timerService.start()
                this.status = TimerStatus.RUNNING
                this.startSensor()
              }
            })

          Button($r('app.string.main_reset'))
            .fontSize($r('app.float.button_font_size'))
            .width(ConstantUI.BUTTON_WIDTH_HALF)
            .onClick(() => {
              this.timerService.reset()
              this.status = TimerStatus.STOPPED
              this.stopSensor()
            })
        }
      }
      .padding(ConstantUI.SIZE_20)
      .width(ConstantUI.FULL_WIDTH)
      .height(ConstantUI.FULL_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [
          [$r('app.color.base_background_gradient_start'), 0.0],
          [$r('app.color.base_background_gradient_end'), 1.0]
        ]
      })
    }
    .colors($r('app.color.gauge'))
    .width(ConstantUI.FULL_WIDTH)
    .height(ConstantUI.FULL_HEIGHT)
    .indicator(null)
    .strokeWidth(ConstantUI.SIZE_10)
    .trackShadow({ radius: 3, offsetX: 3, offsetY: 3 })
  }

  startSensor() {
    sensor.subscribeAccelerometer({
      interval: 'game',
      success: (data) => {
        const now = Date.now()
        const deltaTime = now - this.lastTimestamp

        if (deltaTime < 600) {return}

        const deltaZ = data.z - this.lastZ
        const threshold = 2.5

        if (this.timerService.status === TimerStatus.RUNNING) {
          if (deltaZ < -threshold && !this.isDown) {
            this.isDown = true
          } else if (deltaZ > threshold && this.isDown) {
            this.timerService.incrementRep()
            this.isDown = false
          }
        }

        this.lastZ = data.z
        this.lastTimestamp = now
      },
      fail: (err) => {
        console.error('[SENSOR ERROR]', JSON.stringify(err))
      }
    })
  }

  stopSensor() {
    sensor.unsubscribeAccelerometer()
  }

  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / ConstantUI.CONST_60).toString().padStart(2, '0')
    const secs = (seconds % ConstantUI.CONST_60).toString().padStart(2, '0')
    return `${mins}:${secs}`
  }
  pageTransition() {
    PageTransitionEnter({
      type: RouteType.Push,
      duration: 600 })
      .slide(SlideEffect.Right)

    PageTransitionEnter({
      type: RouteType.Pop,
      duration: 600 })
      .slide(SlideEffect.Left)

    PageTransitionExit({
      type: RouteType.Push,
      duration: 600 })
      .slide(SlideEffect.Left)

    PageTransitionExit({
      type: RouteType.Pop,
      duration: 600 })
      .slide(SlideEffect.Right)
  }
}
