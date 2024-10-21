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

;; Governance parameters
(define-map governance-parameters
    { parameter: (string-ascii 50) }
    { value: uint }
)

;; Initialize governance parameters
(begin
    (map-set governance-parameters { parameter: "min-validators" } { value: u3 })
    (map-set governance-parameters { parameter: "approval-threshold" } { value: u70 })
)

;; Create a new skill type
(define-public (create-skill (name (string-ascii 64)) (description (string-ascii 256)) (required-votes uint))
    (let
        ((skill-id (+ (var-get skill-counter) u1)))
        (asserts! (is-eq tx-sender contract-owner) (err u403))
        (map-set skills
            { skill-id: skill-id }
            {
                name: name,
                description: description,
                required-votes: required-votes,
                created-by: tx-sender
            }
        )
        (var-set skill-counter skill-id)
        (ok skill-id)
    )
)

;; Request skill verification
(define-public (request-verification (skill-id uint))
    (let
        ((verification-status (map-get? skill-verifications { skill-id: skill-id, user: tx-sender })))
        (asserts! (is-none verification-status) (err u401))
        (map-set skill-verifications
            { skill-id: skill-id, user: tx-sender }
            {
                status: "pending",
                votes: u0,
                validators: (list),
                badge-id: none
            }
        )
        (ok true)
    )
)

;; Vote on skill verification
(define-public (vote-on-verification (skill-id uint) (user principal) (approve bool))
    (let
        ((verification (unwrap! (map-get? skill-verifications { skill-id: skill-id, user: user }) (err u404)))
         (skill (unwrap! (map-get? skills { skill-id: skill-id }) (err u404)))
         (validators (get validators verification)))

        ;; Check if validator has already voted
        (asserts! (not (is-some (index-of validators tx-sender))) (err u401))

        ;; Update verification
        (map-set skill-verifications
            { skill-id: skill-id, user: user }
            {
                status: (if (>= (+ (get votes verification) u1) (get required-votes skill))
                    (if approve "approved" "rejected")
                    "pending"
                ),
                votes: (+ (get votes verification) u1),
                validators: (append validators tx-sender),
                badge-id: (if (and approve (>= (+ (get votes verification) u1) (get required-votes skill)))
                    (some (+ (var-get badge-counter) u1))
                    (get badge-id verification))
            }
        )

        ;; Mint NFT badge if approved
        (if (and approve (>= (+ (get votes verification) u1) (get required-votes skill)))
            (begin
                (nft-mint? skill-badge (+ (var-get badge-counter) u1) user)
                (var-set badge-counter (+ (var-get badge-counter) u1))
            )
            false
        )

        (ok true)
    )
)
