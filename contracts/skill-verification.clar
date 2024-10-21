;; skill-verification.clar
;; Main contract for skill verification and NFT minting

(define-non-fungible-token skill-badge uint)

(define-map skills
    { skill-id: uint }
    {
        name: (string-ascii 64),
        description: (string-ascii 256),
        required-votes: uint,
        created-by: principal
    }
)

(define-map skill-verifications
    { skill-id: uint, user: principal }
    {
        status: (string-ascii 20),
        votes: uint,
        validators: (list 50 principal),
        badge-id: (optional uint)
    }
)

(define-data-var skill-counter uint u0)
(define-data-var badge-counter uint u0)
