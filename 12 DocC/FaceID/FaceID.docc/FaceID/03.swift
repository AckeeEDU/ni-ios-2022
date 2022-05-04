let context = CAContext()

var error: NSError?
let permissions = context.canEvaluatePolicy(
    .deviceOwnerAuthentication,
    error: &error
)

guard permissions else { return }

context.evaluatePolicy(
    .deviceOwnerAuthenticationWithBiometrics,
    localizedReason: "FaceID login"
) { success, error in
    if let error = error {
        // Handle error
    } else if success {
        // Handle success case
    }
}
