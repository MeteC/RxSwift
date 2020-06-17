import RxSwift
import Foundation

var str = Observable<String>.just("Helloe").delay(.milliseconds(301), scheduler: MainScheduler.instance)

str
    .timeout(.milliseconds(300), other: Observable.just("TIMEOUT"), scheduler: MainScheduler.instance)
    .subscribe(onNext: { print($0)})


let timer = Observable<Int>
    .interval(.milliseconds(100), scheduler: MainScheduler.instance)
    .take(.seconds(1), scheduler: MainScheduler.instance)
//    .delay(.milliseconds(100), scheduler: MainScheduler.instance)
    .share()        

timer.debug("timer1").subscribe()
timer.delay(.milliseconds(600), scheduler: MainScheduler.instance).debug("timer2").subscribe()

// so even with share, interval is cold and gets restarted for each subscribe?
