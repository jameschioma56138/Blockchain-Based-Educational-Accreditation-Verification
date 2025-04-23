;; Program Registration Contract
;; Records details of academic offerings

(define-data-var admin principal tx-sender)

;; Map to store registered programs
(define-map registered-programs
  {program-id: uint}
  {institution-id: uint,
   name: (string-ascii 100),
   description: (string-ascii 255),
   credits: uint,
   registered-at: uint})

;; Function to register a program
(define-public (register-program
                (program-id uint)
                (institution-id uint)
                (name (string-ascii 100))
                (description (string-ascii 255))
                (credits uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can register
    (map-set registered-programs
      {program-id: program-id}
      {institution-id: institution-id,
       name: name,
       description: description,
       credits: credits,
       registered-at: block-height})
    (ok program-id)))

;; Function to get program details
(define-read-only (get-program-details (program-id uint))
  (map-get? registered-programs {program-id: program-id}))

;; Function to get all programs for an institution
;; Note: Clarity doesn't have a direct way to filter maps, so we'll use a different approach
(define-read-only (get-program-by-institution-id (program-id uint) (institution-id uint))
  (let ((program (map-get? registered-programs {program-id: program-id})))
    (and (is-some program)
         (is-eq (get institution-id (unwrap-panic program)) institution-id))))

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)))
