;; Dbcoin fungible token smart contract
;; A simple, non-trait FT with single initialization and transfer support.

(define-constant ERR-NOT-AUTHORIZED (err u100))          ;; reserved if you later add admin-only functions
(define-constant ERR-ALREADY-INITIALIZED (err u101))     ;; token can only be initialized once
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))

;; -----------------------------------------------------------------------------
;; Token metadata
;; -----------------------------------------------------------------------------

(define-read-only (get-name)
  (ok "dbcoin"))

(define-read-only (get-symbol)
  (ok "DB"))

(define-read-only (get-decimals)
  (ok u6))

;; -----------------------------------------------------------------------------
;; Storage
;; -----------------------------------------------------------------------------

(define-data-var total-supply uint u0)
(define-data-var initialized bool false)

(define-map balances
  { account: principal }
  { balance: uint })

;; -----------------------------------------------------------------------------
;; Read-only views
;; -----------------------------------------------------------------------------

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance-of (account principal))
  (let ((maybe-balance (map-get? balances { account: account })))
    (ok (default-to u0 (match maybe-balance bal (get balance bal) u0)))) )

;; -----------------------------------------------------------------------------
;; Internal helpers
;; -----------------------------------------------------------------------------

(define-private (internal-transfer (sender principal) (recipient principal) (amount uint))
  (let (
        (sender-entry (map-get? balances { account: sender }))
        (recipient-entry (map-get? balances { account: recipient }))
        (sender-balance (default-to u0 (match sender-entry s (get balance s) u0)))
        (recipient-balance (default-to u0 (match recipient-entry r (get balance r) u0)))
       )
    (if (< sender-balance amount)
        ERR-INSUFFICIENT-BALANCE
        (begin
          (map-set balances { account: sender } { balance: (- sender-balance amount) })
          (map-set balances { account: recipient } { balance: (+ recipient-balance amount) })
          (ok true)))))

;; -----------------------------------------------------------------------------
;; Public entrypoints
;; -----------------------------------------------------------------------------

;; One-time initialization that mints an initial supply to the chosen recipient.
;; Anyone can call this, but only once for the lifetime of the contract.
(define-public (initialize (recipient principal) (amount uint))
  (if (var-get initialized)
      ERR-ALREADY-INITIALIZED
      (begin
        (let ((current-balance (default-to u0
                               (match (map-get? balances { account: recipient }) r (get balance r) u0))))
          (map-set balances { account: recipient } { balance: (+ current-balance amount) }))
        (var-set total-supply amount)
        (var-set initialized true)
        (ok true))))

;; Transfer tokens from sender to recipient.
;; The tx-sender must match the declared sender to authorize the movement.
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (if (is-eq tx-sender sender)
      (internal-transfer sender recipient amount)
      ERR-NOT-AUTHORIZED))
