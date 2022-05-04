let context = CAContext()

var error: NSError?
let permissions = context.canEvaluatePolicy(
    .deviceOwnerAuthentication,
    error: &error
)