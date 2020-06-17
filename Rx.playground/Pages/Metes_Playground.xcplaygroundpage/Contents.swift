
import RxSwift
import RxCocoa


// throw strings as errors
extension String : Error {}

// Test: we have an input that puts out values and then has an error, and we have a subject that is both observer and observable.
// we get the subject to forward on messages from our erroring input
let erroredInput: Observable<String> = Observable.create({ (observer) -> Disposable in
    observer.onNext("one")
    observer.onNext("2")
    observer.onError("Whoops!")
    observer.onNext("three")
    observer.onCompleted()
    
    return Disposables.create()
})

let safeInput: Observable<String> = Observable.create({ (observer) -> Disposable in
    observer.onNext("a")
    observer.onNext("b")
    observer.onNext("c")
    observer.onCompleted()
    
    return Disposables.create()
})


var output = PublishSubject<String>()
let input = Observable.from(["fromA","fromB", "fromC","fromD"]) // another input using from()


var merger = Observable.merge(input, safeInput, erroredInput)

// first we have to subscribe to our subject
output.subscribe(onNext: { print($0) })

output.onNext("output alive")

// subscribe to our merger drives its inputs
merger
    .catchErrorJustReturn("caught error at merger")
    .subscribe(output)

output.onNext("output dead")

// when we get the error, the merger fails from then on out, as does the subject! even if we catch it at merger.
// we'd need the erroring part of the merger to already be handling its own errors well.

print("\n--RESTARTING--\n")

let cheeky = BehaviorSubject<String>(value: "CHEEKY")
let cheeky2 = BehaviorSubject<String>(value: "CHEEKY2")

merger = Observable.merge(input, 
                          safeInput, 
                          cheeky,
                          erroredInput.catchErrorJustReturn("caught error at input")
)

output = PublishSubject<String>()
output.subscribe(onNext: { print($0) }, onCompleted: { print("output finished") })

output.onNext("output alive")

merger.subscribe(output)

// Couldn't subscribe anything else to the subject after this, or push any new values!
// output seems to catch merger's completed signal. So we added a cheeky Subject above that doesn't complete,
// and this way our output does indeed stay alive:

output.onNext("output still alive. subscribing from input one more time")

// before we subscribe to input again, let's subscribe to yet another subject, and input messages on both our subscribed subjects..
cheeky2.subscribe(output)
cheeky.onNext("CHEEKY next")
cheeky2.onNext("CHEEKY2 next")

// they both come through. Now lets subscribe to a completing observable
input.subscribe(output)

// NOW output is completed since input completed. so any onComplete message seems to trigger the subject to complete.

