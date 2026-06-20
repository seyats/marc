import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

public enum FirebaseBootstrap {
    public static func configureIfPossible() {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil, Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        #endif
    }
}
