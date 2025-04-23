;; Evaluation Tracking Contract
;; Documents accreditation review process

(define-data-var admin principal tx-sender)

;; Evaluation status enum: 0=Pending, 1=In Progress, 2=Completed
(define-constant STATUS_PENDING u0)
(define-constant STATUS_IN_PROGRESS u1)
(define-constant STATUS_COMPLETED u2)

;; Map to store evaluations
(define-map evaluations
  {evaluation-id: uint}
  {institution-id: uint,
   program-id: uint,
   evaluator: principal,
   status: uint,
   comments: (string-ascii 255),
   started-at: uint,
   completed-at: (optional uint)})

;; Function to start an evaluation
(define-public (start-evaluation
                (evaluation-id uint)
                (institution-id uint)
                (program-id uint)
                (evaluator principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1)) ;; Only admin can start
    (map-set evaluations
      {evaluation-id: evaluation-id}
      {institution-id: institution-id,
       program-id: program-id,
       evaluator: evaluator,
       status: STATUS_IN_PROGRESS,
       comments: "",
       started-at: block-height,
       completed-at: none})
    (ok evaluation-id)))

;; Function to complete an evaluation
(define-public (complete-evaluation
                (evaluation-id uint)
                (comments (string-ascii 255)))
  (let ((evaluation (unwrap! (map-get? evaluations {evaluation-id: evaluation-id}) (err u1))))
    (begin
      (asserts! (is-eq tx-sender (get evaluator evaluation)) (err u2)) ;; Only assigned evaluator
      (map-set evaluations
        {evaluation-id: evaluation-id}
        (merge evaluation
               {status: STATUS_COMPLETED,
                comments: comments,
                completed-at: (some block-height)}))
      (ok evaluation-id))))

;; Function to get evaluation details
(define-read-only (get-evaluation-details (evaluation-id uint))
  (map-get? evaluations {evaluation-id: evaluation-id}))

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1))
    (var-set admin new-admin)
    (ok true)))
