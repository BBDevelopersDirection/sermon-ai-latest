We want to implement a subscription creation and validation system that works as follows:

Check for existing subscription

When the user tries to subscribe, first check the Users collection in Firestore for that user’s document.

If a valid subscriptionId already exists, do not create a new one.

If no subscription exists, create a new subscription in Razorpay and save its ID (subscriptionId) to the user document.

After successful payment (autopay)

Once Razorpay Autopay is completed successfully, mark this subscription as active and ensure it is not created again in the future for the same user.

7-day validation rule

After the subscription is created, start a 7-day timer or scheduled check.

Within these 7 days:

Periodically verify the subscription status via Razorpay API.

If the status becomes active or payment_captured, consider it successful.

If, after 7 days, it’s still not active or payment_captured, then check if it’s subscription_authenticated.

If it is subscription_authenticated, keep it active.

Otherwise, handle it as failed or pending.

Firebase Utils collection

Use a Utils collection in Firestore (e.g., Utils/{userId}) to store:

Temporary data about subscription status

Payment verification logs

Retry counts, timestamps, etc.

Summary

Don’t recreate subscriptions if one already exists.

After creation, monitor for 7 days.

Accept as valid if the subscription becomes active, payment_captured, or subscription_authenticated.

Use Utils collection for any background tracking or data persistence.