

import UserMessagingPlatform


@available(iOS 13.0, *)
public class UMPDialog {
    
    public init(){}
    @MainActor public func loadForm(_ completion: @escaping () -> Void) {
        UMPConsentForm.load(completionHandler: { form, loadError in
            if loadError != nil {
                print("MYERROR #2 \(String(describing: loadError))")
                completion()
            } else {
                print("CONSENT STATUS: \(UMPConsentInformation.sharedInstance.consentStatus)")
                if UMPConsentInformation
                    .sharedInstance.consentStatus == .required {
                    
                    if UMPConsentInformation
                        .sharedInstance.consentStatus == .obtained {
                        completion()
                    } else {
                        form?.present(from: self.rootController, completionHandler: { _ in
                            completion()
                        })
                    }
                }
            }
        })
    }

    @MainActor  public func trackingConsentFlow(completion: @escaping () -> Void) {
        let umpParams = UMPRequestParameters()
        let debugSettings = UMPDebugSettings()
        debugSettings.geography = UMPDebugGeography.EEA
        umpParams.debugSettings = debugSettings
        umpParams.tagForUnderAgeOfConsent = false

        UMPConsentInformation
            .sharedInstance
            .requestConsentInfoUpdate(with: umpParams,
             completionHandler: { error in
             if error != nil {
                print("MYERROR #1 \(String(describing: error))")
                completion()
               } else {
                 let formStatus = UMPConsentInformation.sharedInstance.formStatus
                 print("FORM STATUS: \(formStatus)")
               if formStatus == .available {
                   self.loadForm(completion)
                 } else {
                    completion()
                 }
            }
        })
    }
    
    @available(iOS 13.0, *)
    @MainActor public var rootController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            // Fallback for older iOS versions
            return UIApplication.shared.windows.first?.rootViewController
        }
        
        var root = window.rootViewController
        while let presenter = root?.presentedViewController {
            root = presenter
        }
        return root
    }
}

