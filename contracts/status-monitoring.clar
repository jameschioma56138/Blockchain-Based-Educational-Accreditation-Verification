;; Status Monitoring Contract
;; Tracks current accreditation standing

(define-data-var admin principal tx-sender)

;; Accreditation status enum: 0=Not Accredited, 1=Provisional, 2=Fully Accredited
(define-constant STATUS_NOT_ACCREDITED u0)
(define-constant STATUS_PROVISIONAL u1)
(define-constant STATUS_FULLY_ACCREDITED u2)

;; Map to store accreditation status
(define-map accreditation-status
  {institution-id: uint, program-id: uint}
  {status: uint,
   expiration-height: uint,
   last-updated: uint,
   updated-by: principal})

;; Function to set accreditation status
(define-public (set-accreditation-status
                (institution-id uint)
                (program-id uint)
                (status uint)
                (expiration-height uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can set status
    (asserts! (or (is-eq status STATUS_NOT_ACCREDITED)
                 (is-eq status STATUS_PROVISIONAL)
                 (is-eq status STATUS_FULLY_ACCREDITED))
             (err u2)) ;; Valid status check
    (map-set accreditation-status
      {institution-id: institution-id, program-id: program-id}
      {status: status,
       expiration-height: expiration-height,
       last-updated: block-height,
       updated-by: tx-sender})
    (ok true)))

;; Function to check if accreditation is valid
(define-read-only (is-accreditation-valid (institution-id uint) (program-id uint))
  (let ((status-data (map-get? accreditation-status {institution-id: institution-id, program-id: program-id})))
    (if (is-some status-data)
        (let ((unwrapped-data (unwrap-panic status-data)))
          (and (> (get expiration-height unwrapped-data) block-height)
               (or (is-eq (get status unwrapped-data) STATUS_PROVISIONAL)
                   (is-eq (get status unwrapped-data) STATUS_FULLY_ACCREDITED))))
        false)))

;; Function to get accreditation details
(define-read-only (get-accreditation-details (institution-id uint) (program-id uint))
  (map-get? accreditation-status {institution-id: institution-id, program-id: program-id}))

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)))
