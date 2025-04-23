;; Institution Verification Contract
;; Validates legitimate educational entities

(define-data-var admin principal tx-sender)

;; Map to store verified institutions
(define-map verified-institutions
  {institution-id: uint}
  {name: (string-ascii 100),
   location: (string-ascii 100),
   verified: bool,
   verified-by: principal,
   verified-at: uint})

;; Function to verify an institution
(define-public (verify-institution (institution-id uint) (name (string-ascii 100)) (location (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can verify
    (map-set verified-institutions
      {institution-id: institution-id}
      {name: name,
       location: location,
       verified: true,
       verified-by: tx-sender,
       verified-at: block-height})
    (ok institution-id)))

;; Function to check if an institution is verified
(define-read-only (is-institution-verified (institution-id uint))
  (default-to false (get verified (map-get? verified-institutions {institution-id: institution-id}))))

;; Function to get institution details
(define-read-only (get-institution-details (institution-id uint))
  (map-get? verified-institutions {institution-id: institution-id}))

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)))
