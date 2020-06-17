
import RxSwift
import RxCocoa

// "How do I incorporate a latest reactive "state" inside another observable's event without storing state?"
/// - `withLatestFrom`

let reactiveState = Observable<Bool>.from([false, true, true, false])

cookbook("withLatestFrom") {
    let buttonTaps = Observable<Void>.from([(),(),(),(),(),(),(),(),])
    
    // trigger button presses
    buttonTaps
        .withLatestFrom(reactiveState)
        .subscribe(
        onNext: { result in
            print("Tap with set state \(result)")
    })
    
    // Expect: tap with false, true, true, false, false, false on out
}
    
cookbook("withLatestFrom combination") {
    // What if my button taps had their own data as well?
    let infoButtonTaps = Observable<Int>.from([1,2,3,2,0,4,5,4,4,6])
    
    infoButtonTaps
        .withLatestFrom(reactiveState) { return ($0,$1) }
        .subscribe(
            onNext: { result in
                print("Info tap with set state \(result)")
        })
}
