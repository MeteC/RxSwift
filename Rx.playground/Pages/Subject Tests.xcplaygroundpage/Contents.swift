import Foundation
import RxSwift

enum PublishVideoState {
    case unpublished, waiting, publishing, published
}

extension PublishVideoState: CustomStringConvertible {
    var description: String {
        switch self {
        case .published: return "published"
        case .unpublished: return "unpublished"
        case .waiting: return "waiting"
        case .publishing: return "publishing"
        }
    }
}

let videoState = BehaviorSubject<PublishVideoState>(value: .unpublished)
let cameraConfig = BehaviorSubject<String?>(value: nil)

// when camera config is valid, and videoState is waiting, we want to call publish()

// zip requires pairs


// let's combine a big mess so we get video state, camera config, and PREVIOUS camera config (track changes) 
let combo = Observable.combineLatest(videoState.distinctUntilChanged(), cameraConfig.distinctUntilChanged())

// filter on waiting AND camera config valid
combo
    .debug("Combo")
    .filter { $0.0 == .waiting && $0.1 != nil }
    .subscribe( onNext: {
        print("Got \($0.0) and camera config \($0.1!) - publish")
    })


// After SO MUCH fucking around, I found you can get historical data zipped up using skip.
// so now historicCamera is an observable of changes to camera config.
let historicCamera = Observable.zip(cameraConfig, cameraConfig.skip(1)).map { $0.0 != $0.1 }

// Now to combine history of camera changes with current video state, and then take a history of that too...
// because both camera config and video state changes trigger these, if you change video state to published when the last history of camera config included a change, you will perceive both "published" and "changed camera", which is your end state. However that's erroneous, because we consider that as you change to published, you want to ignore any older camera history. 
let historicCombo = Observable.combineLatest(videoState.distinctUntilChanged(), historicCamera)
let changeWatcher = Observable.zip(historicCombo, historicCombo.skip(1)) // bloody hell

// so changeWatcher is now watching the history of the combo of distinct video state changes, and camera configuration changes.
// we can spell it out a little gentler now by making an observable mapping when camera config changes and video state is AND was published - i.e. already was published and didn't change this time
// now compare camera histories and video state changes..
    
changeWatcher
    .filter { 
        // we want to detect when camera state changed but video state was already on published
        // we don't want when camera state history indicates a change but video state changed FROM published
        let bothPublished = $0.0 == .published && $1.0 == .published
        let camChanged = $1.1
        return bothPublished && camChanged }
    .debug("CHANGE WATCHER")
    .subscribe( onNext: {
        print("Got video \($1.0), and camera change \($1.1). Unpublish.")
    })

//historicCombo
//    .filter { $0.0.0 == .published && $0.1.0 != $0.1.1 }
//    .debug("HISTORIC")
//    .subscribe( onNext: {
//        print("Got video \($0.0), previous \($0.1.0) and next \($0.1.1). Unpublish.")
//    })

cameraConfig.onNext("1")
cameraConfig.onNext("2")

videoState.onNext(.waiting) // trigger publish note
print("+")

cameraConfig.onNext("3") // trigger publish note
print("+")

//cameraConfig.onNext("3")
videoState.onNext(.waiting)
cameraConfig.onNext(nil)

videoState.onNext(.publishing)
videoState.onNext(.published)

videoState.onNext(.publishing)
videoState.onNext(.published)

cameraConfig.onNext("3")
print("-")

cameraConfig.onNext("4") // trigger unpublish note
print("-")

cameraConfig.onNext("4")

cameraConfig.onNext("5") // trigger unpublish note
print("-")

videoState.onNext(.published)
videoState.onNext(.publishing)
videoState.onNext(.published)

cameraConfig.onNext("6") // trigger unpublish note
print("-")

videoState.onNext(.waiting)
print("+")

cameraConfig.onNext(nil)
cameraConfig.onNext("7")
print("+")

//cameraConfig.onNext("2")
// 
//videoState.onNext(.unpublished)


// publish when switch to waiting and switch to cameraConfig valid 
