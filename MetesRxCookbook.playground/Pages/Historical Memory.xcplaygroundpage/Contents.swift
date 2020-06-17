
import RxSwift
import RxCocoa

// "How do I keep a memory of what happened in (a) previous step(s)?"
// "How do I track deltas rather than event units?"

/// - You can get historical data using `zip` and `skip`.

cookbook("history / track deltas") {
    let input = Observable.from(["a", "ab", "abc", "ac", "d", "e"])
    
    let deltas = Observable
        .zip(input, input.skip(1))
        .debug("Delta")
        .subscribe()

}
