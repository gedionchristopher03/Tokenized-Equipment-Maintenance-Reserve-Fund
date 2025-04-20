;; Asset Registration Contract
;; Records details of capital equipment

(define-data-var last-asset-id uint u0)

;; Asset map: asset-id -> asset details
(define-map assets
  { asset-id: uint }
  {
    name: (string-ascii 100),
    purchase-date: uint,
    purchase-cost: uint,
    expected-lifetime-days: uint,
    owner: principal
  }
)

;; Register a new asset
(define-public (register-asset
    (name (string-ascii 100))
    (purchase-date uint)
    (purchase-cost uint)
    (expected-lifetime-days uint))
  (let
    (
      (new-id (+ (var-get last-asset-id) u1))
      (caller tx-sender)
    )
    (asserts! (> (len name) u0) (err u1)) ;; Name must not be empty
    (asserts! (> purchase-cost u0) (err u2)) ;; Cost must be positive
    (asserts! (> expected-lifetime-days u0) (err u3)) ;; Lifetime must be positive

    ;; Update the asset map
    (map-set assets
      { asset-id: new-id }
      {
        name: name,
        purchase-date: purchase-date,
        purchase-cost: purchase-cost,
        expected-lifetime-days: expected-lifetime-days,
        owner: caller
      }
    )

    ;; Update the last asset ID
    (var-set last-asset-id new-id)

    ;; Return the new asset ID
    (ok new-id)
  )
)

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (map-get? assets { asset-id: asset-id })
)

;; Check if caller is the asset owner
(define-read-only (is-asset-owner (asset-id uint) (caller principal))
  (let ((asset (map-get? assets { asset-id: asset-id })))
    (if (is-some asset)
      (is-eq (get owner (unwrap-panic asset)) caller)
      false
    )
  )
)

;; Get total number of registered assets
(define-read-only (get-asset-count)
  (var-get last-asset-id)
)
